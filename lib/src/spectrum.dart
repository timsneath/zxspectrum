import 'dart:typed_data';

import 'package:dart_z80/dart_z80.dart';

import 'display.dart';
import 'memory.dart';
import 'ula.dart';

/// Represents the ZX Spectrum 48K.
///
/// Encapsulates the various components (memory, ULA and Z80 microprocessor),
/// and coordinates between them.
class Spectrum {
  /// The computer memory
  late final SpectrumMemory memory;

  /// The ULA (uncommitted logic array)
  late final ULA ula;

  /// The Z80A microprocessor
  late final Z80 z80;

  /// A BMP representing the current frame displayed on the screen.
  Uint8List get displayAsBitmap => Display.bmpImage(memory);

  Spectrum(Uint8List rom) {
    memory = SpectrumMemory(isRomProtected: true);
    memory.load(0x0000, rom.buffer.asUint8List(), ignoreRomProtection: true);
    ula = ULA();
    z80 = Z80(memory,
        startAddress: 0x0000, onPortRead: readPort, onPortWrite: writePort);
  }

  /// Writes a value to an I/O port.
  void writePort(int addressBus, int value) {
    // Every even I/O address will address the ULA, but to avoid problems with
    // other I/O devices only Port 0xfe should be used.
    if (addressBus % 2 == 0) {
      ula.write(value);
    }
  }

  /// Reads a value from an I/O port.
  int readPort(int addressBus) {
    // Every even I/O address will address the ULA, but to avoid problems with
    // other I/O devices only Port 0xfe should be used.
    if (addressBus % 2 == 0) {
      return ula.read(addressBus);
    } else {
      return highByte(addressBus);
    }
  }

  /// Resets the ZX Spectrum (equivalent to a power cycle).
  void reset() {
    memory.reset();
    ula.reset();
    z80.reset();
  }
}
