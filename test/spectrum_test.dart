import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import 'package:zxspectrum/zxspectrum.dart';

void main() {
  test('Reset is successful', () {
    final rom = File('roms/48.rom').readAsBytesSync();
    final spectrum = SpectrumFFI(rom);
    spectrum.loadMemory(
        0x4000, List.generate(0x10000 - 0x4000, (index) => 0xFF));
    spectrum.reset();
    final resetMemory = spectrum.memory.read(0x4000, 0x10000 - 0x4000);
    expect(resetMemory, everyElement(0));
  });

  test('Boot is successful', () {
    const breakpoint = 0x15e6;
    final rom = File('roms/48.rom').readAsBytesSync();
    final spectrum = SpectrumFFI(rom);
    while (spectrum.ctx.ref.PC != breakpoint) {
      spectrum.z80b.Z80Execute(spectrum.ctx);
    }
    expect(spectrum.ctx.ref.R1.wr.AF, equals(0x0018));
    expect(spectrum.ctx.ref.R1.wr.BC, equals(0x174b));
    expect(spectrum.ctx.ref.R1.wr.DE, equals(0x0006));
    expect(spectrum.ctx.ref.R1.wr.HL, equals(0x107f));
    // expect(spectrum.ctx.ref.R1.wr.IX, equals(0xffff));
    // expect(spectrum.ctx.ref.R1.wr.IY, equals(0x5c3a));
    // expect(spectrum.ctx.ref.R1.wr.SP, equals(0xff4c));
  });
}
