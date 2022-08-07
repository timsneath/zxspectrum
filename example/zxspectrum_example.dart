import 'dart:io';

import 'package:zxspectrum/zxspectrum.dart';

// good breakpoint representing a time when the machine has booted
const breakpoint = 0x15e6;

void main() async {
  final rom = File('roms/48.rom').readAsBytesSync();
  final spectrum = Spectrum(rom);

  final stopwatch = Stopwatch()..start();
  final start = stopwatch.elapsedMicroseconds;

  while (spectrum.z80.pc != breakpoint) {
    spectrum.z80.executeNextInstruction();
  }

  final end = stopwatch.elapsedMicroseconds;

  print('Took ${(end - start) / 1000}ms to boot.');
}
