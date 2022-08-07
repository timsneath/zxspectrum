// display_test.dart -- test display system

import 'package:test/test.dart';
import 'package:dart_z80/dart_z80.dart';

import 'package:zxspectrum/zxspectrum.dart';

void main() {
  test('Basic display test', () {
    final memory = SpectrumMemory(isRomProtected: false);
    final z80 = Z80(memory, startAddress: 0xA000);
    z80.reset();

    // final buffer = memory.displayBuffer;
    final image = Display.imageBuffer(memory);
    expect(image.lengthInBytes, equals(256 * 192 * 4));
  });
}
