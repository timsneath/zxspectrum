// ula.dart -- ports and input for ZX Spectrum

import 'package:dart_z80/dart_z80.dart';

import '../zxspectrum.dart';

// See http://www.worldofspectrum.org/ZXBasicManual/zxmanchap23.html and
// https://worldofspectrum.org/faq/reference/48kreference.htm
class ULA {
  static const _keyMap = <int, List<String>>{
    0x00: ['SHIFT', 'Z', 'X', 'C', 'V'],
    0x01: ['A', 'S', 'D', 'F', 'G'],
    0x02: ['Q', 'W', 'E', 'R', 'T'],
    0x03: ['1', '2', '3', '4', '5'],
    0x04: ['0', '9', '8', '7', '6'],
    0x05: ['P', 'O', 'I', 'U', 'Y'],
    0x06: ['ENTER', 'L', 'K', 'J', 'H'],
    0x07: ['SPACE', 'SYMBL', 'M', 'N', 'B']
  };

  // Multiple keys can be pressed at once, so we create a set of keys from which
  // we add or remove based on interactions.
  final Set<String> _keysPressed = {};

  ///
  bool _earMicPort = true;

  /// The current border color.
  SpectrumColor screenBorder = SpectrumColor.fromName(SpectrumColors.black);

  /// Resets the ULA, for example as a result of a power cycle.
  void reset() {
    screenBorder = SpectrumColor.fromName(SpectrumColors.black);
    _earMicPort = false;
    _keysPressed.clear();
  }

  /// Writes a value to the ULA.
  ///
  /// Values written are interpreted as follows:
  ///
  /// ```
  ///   Bit   7   6   5   4   3   2   1   0
  ///       +-------------------------------+
  ///       |   |   |   | E | M |   Border  |
  ///       +-------------------------------+
  /// ```
  ///
  /// (where E = EAR port and M = MIC port). Per WoS, the EAR and MIC sockets
  /// are connected only by resistors, so activating one activates the other;
  /// the EAR is generally used for output as it produces a louder sound. The
  /// upper bits are unused.
  void write(int value) {
    _earMicPort = ((value & 0x08) == 0x08) | ((value & 0x10) == 0x10);
    screenBorder = SpectrumColor.fromByteValue(value & 0x07);
  }

  void keyDown(String keycap) => _keysPressed.add(keycap);

  void keyUp(String keycap) => _keysPressed.remove(keycap);

  /// Reads a value from the ULA.
  ///
  /// Bits 0 through 4 express the keys pressed.
  /// Bits 5 and 7 are always set.
  /// Bit 6 is the EAR input bit.
  int read(int addressBus) {
    // Reading the port 0xFE with a zero set in one of the eight high address
    // bus lines will return an 8-bit value, of which the least significant five
    // bits represent a bitmap of the value, so for example: if the 'V' key is
    // held down, the value nnn10000 can be read from port 0xFEFE. If multiple
    // zeroes are set, the values are ANDed together.
    //
    // More information at:
    //   http://www.breakintoprogram.co.uk/computers/zx-spectrum/keyboard

    final halfRowSelectorBitmask = highByte(addressBus);
    var output = 0xFF;

    // Multiple address lines may be cleared.
    for (var bit = 0; bit < 8; bit++) {
      if (!isBitSet(halfRowSelectorBitmask, bit)) {
        // Now we need to test whether the specific half row contains one of the
        // pressed keys. If so, we clear that bit from the output.
        final halfRow = _keyMap[bit]!;
        for (var key = 0; key < 5; key++) {
          if (_keysPressed.contains(halfRow[key])) {
            output = resetBit(output, key);
          }
        }
      }
    }

    // Now set EAR input
    if (!_earMicPort) {
      output = resetBit(output, 6);
    }

    return output;
  }
}
