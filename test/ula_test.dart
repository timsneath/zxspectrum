import 'package:test/test.dart';
import 'package:zxspectrum/zxspectrum.dart';

void main() {
  group('Keyboard tests', () {
    test('Keyboard Q is pressed', () {
      final ula = ULA();
      ula.keyDown('Q');
      final inByte = ula.read(0xFBFE);
      expect(inByte & 0x01, isZero);
    });

    test('Keyboard SPACE is pressed', () {
      final ula = ULA();
      ula.keyDown('SPACE');
      final inByte = ula.read(0x7FFE);
      expect(inByte & 0x01, isZero);
    });

    test('Keyboard Enter is pressed with a different ULA port', () {
      final ula = ULA();
      ula.keyDown('ENTER');
      final inByte = ula.read(0xBF00);
      expect(inByte & 0x01, isZero);
    });

    test('Keyboard Enter is not detected with a different address', () {
      final ula = ULA();
      ula.keyDown('ENTER');
      final inByte = ula.read(0x7FFE);
      expect(inByte & 0x01, equals(0x01));
    });

    test('No key pressed', () {
      final ula = ULA();
      ula.keyDown('G');
      final inByte = ula.read(0x7FFE);
      expect(inByte, equals(0xFF));
    });

    // // TODO: Some matrix tests
    // test('Keyboard CAPS, B and V correctly fools SPACE to be pressed', () {
    //   final ula = ULA();
    //   ula.keysPressed.addAll(['CAPS', 'B', 'V']);
    //   final inByte = ula.read(0x7FFE);
    //   expect(inByte & 0x01, isZero);
    // });
  });
}
