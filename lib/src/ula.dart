// ula.dart -- ports and input for ZX Spectrum

import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:dart_z80/dart_z80.dart';

// Reading the port on the left side (e.g. 0xFEFE) will return an 8-bit value
// of which the least significant five bits represent a bitmap of the value,
// so for example: if the 'V' key is held down, the value nnn10000 can be read
// from port 0xFEFE.
//
// More information at:
//   See http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard

const _keyMap = <int, List<String>>{
  0xFEFE: ['SHIFT', 'Z', 'X', 'C', 'V'],
  0xFDFE: ['A', 'S', 'D', 'F', 'G'],
  0xFBFE: ['Q', 'W', 'E', 'R', 'T'],
  0xF7FE: ['1', '2', '3', '4', '5'],
  0xEFFE: ['0', '9', '8', '7', '6'],
  0xDFFE: ['P', 'O', 'I', 'U', 'Y'],
  0xBFFE: ['ENTER', 'L', 'K', 'J', 'H'],
  0x7FFE: ['SPACE', 'SYMBL', 'M', 'N', 'B']
};

// See http://www.worldofspectrum.org/ZXBasicManual/zxmanchap23.html and
// https://worldofspectrum.org/faq/reference/48kreference.htm
class ULA {
  /* PORTS */

  // There are 65,536 addressable ports, each of which can read or write an
  // 8-bit value. However, this is a cheap over-simplification for early
  // development: in practice far fewer ports are independently addressable or
  // useful.
  late final ByteData inputPorts;

  late int screenBorder;

  ULA() {
    final importPortList = Uint8List(0x10000);
    inputPorts = ByteData.sublistView(importPortList);
    screenBorder = 0x00;
  }

  void reset() {
    for (var idx = 0; idx < inputPorts.lengthInBytes; idx++) {
      inputPorts.setUint8(idx, 0);
    }

    screenBorder = 0x00;
  }

  /* KEYBOARD */

  // Multiple keys can be pressed at once, so we create a set of keys that
  // we add or remove to based on interactions.
  Set<String> keysPressed = {};

  void keyPressed(String keycap) {
    keysPressed.add(keycap);

    setKeyboardPorts();
  }

  void keyReleased(String keycap) {
    keysPressed.remove(keycap);

    setKeyboardPorts();
  }

  void setKeyboardPorts() {
    // set all keyboard bits high at first
    for (final key in _keyMap.keys) {
      inputPorts.setUint8(key, 0xFF);
    }

    for (final keyPressed in keysPressed) {
      // We should never be in a position where a key doesn't map to a port,
      // or doesn't map to an index in that port. Asserting to fail-fast in
      // this scenario.
      final port = keyPortMap(keyPressed)!;

      final keyBit = _keyMap[port]!.indexOf(keyPressed);
      assert(keyBit != -1);

      var portValue = inputPorts.getUint8(port);
      portValue = resetBit(portValue, keyBit);
      inputPorts.setUint8(port, portValue);
    }
  }

// Gets the port that maps to the keycap
  int? keyPortMap(String keycap) =>
      _keyMap.keys.firstWhereOrNull((port) => _keyMap[port]!.contains(keycap));

  /// Writes a value to the ULA.
  ///
  /// Values written are interpreted as follows:
  ///
  ///   Bit   7   6   5   4   3   2   1   0
  ///       +-------------------------------+
  ///       |   |   |   | E | M |   Border  |
  ///       +-------------------------------+
  ///
  /// (where E = EAR port and M = MIC port). Per WoS, the EAR and MIC sockets
  /// are connected only by resistors, so activating one activates the other;
  /// the EAR is generally used for output as it produces a louder sound. The
  /// upper bits are unused.
  void write(int value) {
    final borderColor = value & 0x07;
    // ignore: unused_local_variable
    final mic = value & 0x08;
    // ignore: unused_local_variable
    final ear = value & 0x10;

    screenBorder = borderColor;
  }

  int read(int addressBus) {
    if (addressBus % 2 == 0) // ULA
    {
      if (_keyMap.containsKey(addressBus)) {
        return inputPorts.getUint8(addressBus);
      }
    }
    return highByte(addressBus);
  }
}
