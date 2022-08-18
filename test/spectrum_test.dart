import 'dart:io';

import 'package:test/test.dart';
import 'package:zxspectrum/zxspectrum.dart';

void main() {
  test('Reset is successful', () {
    final rom = File('roms/48.rom').readAsBytesSync();
    final spectrum = Spectrum(rom);
    spectrum.memory
        .load(0x4000, List.generate(0x10000 - 0x4000, (index) => 0xFF));
    spectrum.reset();
    final resetMemory = spectrum.memory.read(0x4000, 0x10000 - 0x4000);
    expect(resetMemory, everyElement(0));
  });
}
