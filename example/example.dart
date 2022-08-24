import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:zxspectrum/zxspectrum.dart';

// Good breakpoint in 48K ROM that represents a time when the machine has booted
const breakpoint = 0x15e6;

const testRuns = 500;

double median(List<num> list) {
  final copy = List.from(list);
  copy.sort((a, b) => a.compareTo(b));
  var middle = copy.length ~/ 2;
  if (copy.length % 2 == 1) {
    return copy[middle].toDouble();
  } else {
    return (copy[middle - 1] + copy[middle]) / 2.0;
  }
}

int runTest(SpectrumFFI spectrum) {
  // Boots spectrum and runs through to breakpoint
  final stopwatch = Stopwatch()..start();
  final start = stopwatch.elapsedMicroseconds;

  while (spectrum.ctx.ref.PC != breakpoint) {
    spectrum.z80b.Z80Execute(spectrum.ctx);
  }

  final end = stopwatch.elapsedMicroseconds;
  return end - start;
}

void resetTest(SpectrumFFI spectrum) => spectrum.reset();

void main() async {
  final rom = File('roms/48.rom').readAsBytesSync();
  final spectrum = SpectrumFFI(rom);
  final runTimes = <int>[];

  print('Warming up...');
  for (var i = 0; i < 10; i++) {
    runTest(spectrum);
    resetTest(spectrum);
  }

  print('Measuring the speed of $testRuns boot times.');
  for (var i = 0; i < testRuns; i++) {
    runTimes.add(runTest(spectrum));
    resetTest(spectrum);
  }

  final maxMillisecs = runTimes.reduce(math.max) / 1000;
  final minMillisecs = runTimes.reduce(math.min) / 1000;
  final medianMillisecs = median(runTimes) / 1000;

  print('Median boot time: ${medianMillisecs.toStringAsFixed(1)}ms.');
  print('Maximum boot time: ${maxMillisecs.toStringAsFixed(1)}ms.');
  print('Minimum boot time: ${minMillisecs.toStringAsFixed(1)}ms.');
}
