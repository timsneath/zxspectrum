// memory.dart -- implements the ZX Spectrum memory Map

// ZX Spectrum memory map, from:
//    http://www.animatez.co.uk/computers/zx-spectrum/memory-map/
//
// 0x0000-0x3FFF   ROM
// 0x4000-0x57FF   Screen memory
// 0x5800-0x5AFF   Screen memory (color data)
// 0x5B00-0x5BFF   Printer buffer
// 0x5C00-0x5CBF   System variables
// 0x5CC0-0x5CCA   Reserved
// 0x5CCB-0xFF57   Available memory
// 0xFF58-0xFFFF   Reserved
//
// The block of RAM between &4000 and &7FFF is contended, that is access
// to the RAM is shared between the processor and the ULA. The ULA has
// priority access when the screen is being drawn.

import 'dart:typed_data';

import 'package:dart_z80/dart_z80.dart';

extension FillRange on ByteData {
  void fillRange(int start, int end, int value) {
    for (var idx = start; idx < end; idx++) {
      setUint8(idx, value);
    }
  }
}

class SpectrumMemory extends Memory {
  /// The raw memory in the ZX Spectrum 48K
  ///
  /// We treat the memory space as a list of unsigned bytes from 0x0000 to
  /// ramTop. For convenience, we treat the typed data format as an internal
  /// implementation detail, and all external interfaces are as int.
  static const romTop = 0x3FFF;
  static const ramTop = 0xFFFF;

  late final ByteData _memory;

  bool isRomProtected;

  SpectrumMemory({this.isRomProtected = false})
      : _memory = ByteData(ramTop + 1),
        super(0);

  @override
  void reset() {
    if (isRomProtected) {
      _memory.buffer.asUint8List().fillRange(romTop + 1, ramTop + 1, 0);
      // _memory.fillRange(romTop + 1, ramTop + 1, 0);
    } else {
      _memory.buffer.asUint8List().fillRange(0, ramTop + 1, 0);
      // _memory.fillRange(0, ramTop + 1, 0);
    }
  }

  @override
  void load(int origin, Iterable<int> data,
      {bool ignoreRomProtection = false}) {
    final originalRomProtection = isRomProtected;

    isRomProtected = originalRomProtection & !ignoreRomProtection;

    // By loading byte by byte, we ensure that ROM protection is handled even if
    // the memory load attempt spans protected and non-protected space.
    for (var index = 0; index < data.length; index++) {
      writeByte(origin + index, data.elementAt(index));
    }

    isRomProtected = originalRomProtection;
  }

  ByteData get displayBuffer => ByteData.sublistView(_memory, 0x4000, 0x1AFF);

  List<int> toList() => _memory.buffer.asUint8List();

  @override
  int readByte(int address) => _memory.getUint8(address);

  @override
  int readWord(int address) => _memory.getUint16(address, Endian.little);

  // As with a real device, no exception thrown if an attempt is made to
  // write to ROM - the request is just ignored
  @override
  void writeByte(int address, int value) {
    if (address > romTop || !isRomProtected) {
      _memory.setUint8(address, value);
    }
  }

  @override
  void writeWord(int address, int value) {
    if (address > romTop || !isRomProtected) {
      _memory.setUint16(address, value, Endian.little);
    }
  }
}
