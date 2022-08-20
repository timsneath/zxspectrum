import 'dart:io';

import 'package:test/test.dart';
import 'package:zxspectrum/zxspectrum.dart';

void main() {
  test('Reset is successful', () {
    final rom = File('roms/48.rom').readAsBytesSync();
    final spectrum = Spectrum(rom);
    spectrum.loadMemory(
        0x4000, List.generate(0x10000 - 0x4000, (index) => 0xFF));
    spectrum.reset();
    final resetMemory = spectrum.memory.read(0x4000, 0x10000 - 0x4000);
    expect(resetMemory, everyElement(0));
  });

  test('Boot is successful', () {
    const breakpoint = 0x15e6;
    final rom = File('roms/48.rom').readAsBytesSync();
    final spectrum = Spectrum(rom);
    while (spectrum.z80.pc != breakpoint) {
      spectrum.z80.executeNextInstruction();
    }
    expect(spectrum.z80.af, equals(0x0018));
    expect(spectrum.z80.bc, equals(0x174b));
    expect(spectrum.z80.de, equals(0x0006));
    expect(spectrum.z80.hl, equals(0x107f));
    expect(spectrum.z80.ix, equals(0xffff));
    expect(spectrum.z80.iy, equals(0x5c3a));
    expect(spectrum.z80.sp, equals(0xff4c));
  });
}
