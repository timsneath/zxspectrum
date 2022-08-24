import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_z80/dart_z80.dart';
import 'package:ffi/ffi.dart';
import 'package:zxspectrum/src/libz80.dart';

import 'display.dart';
import 'memory.dart';
import 'ula.dart';

typedef Z80DataIn = UnsignedChar Function(Size, UnsignedShort);
typedef Z80DataOut = Void Function(Size, UnsignedShort, UnsignedChar);

/// Represents the ZX Spectrum 48K.
///
/// Encapsulates the various components (memory, ULA and Z80 microprocessor),
/// and coordinates between them.
class SpectrumFFI {
  /// The computer memory
  final SpectrumMemory memory;

  /// The ULA (uncommitted logic array)
  final ULA ula;

  /// The Z80A microprocessor
  // late final Z80 z80;

  /// The libz80 emulator
  late final libz80 z80b;
  late final Pointer<Z80Context> ctx;

  /// Initializes the ZX Spectrum emulator with a given ROM image.
  ///
  /// The ROM image will be loaded at 0x0000.
  SpectrumFFI(Uint8List rom)
      : ula = ULA(),
        memory = SpectrumMemory() {
    loadMemory(0x0000, rom, ignoreRomProtection: true);
    // z80 = Z80(memory,
    //     startAddress: 0x0000, onPortRead: readPort, onPortWrite: writePort);
    z80b = libz80(DynamicLibrary.open('../libz80.so'));
    ctx = calloc<Z80Context>();
    ctx.ref.memRead = Pointer.fromFunction<Z80DataIn>(memRead, 0);
    ctx.ref.memWrite = Pointer.fromFunction<Z80DataOut>(memWrite);
    ctx.ref.ioRead = Pointer.fromFunction<Z80DataIn>(ioRead, 0);
    ctx.ref.ioWrite = Pointer.fromFunction<Z80DataOut>(ioWrite);
  }

  // int memRead(int param, int addr) => memory.readByte(addr);
  // void memWrite(int param, int addr, int data) => memory.writeByte(addr, data);
  // int ioRead(int param, int addr) => readPort(addr);
  // void ioWrite(int param, int addr, int data) => writePort(addr, data);

  /// A BMP representing the current frame displayed on the screen.
  Uint8List get displayAsBitmap => Display.bmpImage(memory);

  /// Load a list of byte data into memory, starting at origin.
  void loadMemory(int origin, Iterable<int> data,
          {bool ignoreRomProtection = false}) =>
      memory.load(origin, data, ignoreRomProtection: ignoreRomProtection);

  /// Handle a key down event
  void keyDown(String key) => ula.keyDown(key);

  /// Handle a key up event
  void keyUp(String key) => ula.keyUp(key);

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
    // z80.reset();
    z80b.Z80RESET(ctx);
  }
}

final rom = File('roms/48.rom').readAsBytesSync();
final spectrum = SpectrumFFI(rom);
int memRead(int param, int addr) => spectrum.memory.readByte(addr);
void memWrite(int param, int addr, int data) =>
    spectrum.memory.writeByte(addr, data);
int ioRead(int param, int addr) => spectrum.readPort(addr);
void ioWrite(int param, int addr, int data) => spectrum.writePort(addr, data);
