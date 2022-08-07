import 'dart:io';
import 'dart:math' as math;

import 'package:zxspectrum/zxspectrum.dart';

// good breakpoint representing a time when the machine has booted
const breakpoint = 0x15e6;

const testRuns = 100;

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

void main() async {
  final rom = File('roms/48.rom').readAsBytesSync();
  final spectrum = Spectrum(rom);

  final runTimes = <int>[];

  print('Measuring the speed of $testRuns boot times.');

  for (var i = 0; i < testRuns; i++) {
    final stopwatch = Stopwatch()..start();
    final start = stopwatch.elapsedMicroseconds;

    while (spectrum.z80.pc != breakpoint) {
      spectrum.z80.executeNextInstruction();
    }

    final end = stopwatch.elapsedMicroseconds;
    runTimes.add(end - start);
    spectrum.reset();
  }

  final maxMillisecs = runTimes.reduce(math.max) / 1000;
  final minMillisecs = runTimes.reduce(math.min) / 1000;
  final medianMillisecs = median(runTimes) / 1000;

  print('Median boot time: ${medianMillisecs.toStringAsFixed(1)}ms.');
  print('Maximum boot time: ${maxMillisecs.toStringAsFixed(1)}ms.');
  print('Minimum boot time: ${minMillisecs.toStringAsFixed(1)}ms.');
}
