// storage.dart -- handles load/save of data

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'spectrum.dart';
import 'package:dart_z80/dart_z80.dart';

class Storage {
  final Spectrum spectrum;

  Z80 get z80 => spectrum.z80;

  const Storage({required this.spectrum});

  void loadBinaryData(ByteData snapshot,
      {int startLocation = 0x4000, int pc = 0x4000}) {
    spectrum.z80.memory.load(startLocation, snapshot.buffer.asUint8List());
    spectrum.z80.pc = pc;
    // z80.sp = pc;
  }

  void loadRom(ByteData snapshot) {
    loadBinaryData(snapshot, startLocation: 0x0000, pc: 0x0000);
  }

  // Documented at https://sinclair.wiki.zxnet.co.uk/wiki/TAP_format
  void loadTAPSnapshot(ByteData snapshot) {
    // TODO: implement
  }

  // Per https://faqwiki.zxnet.co.uk/wiki/SNA_format
  // the snapshot format has a 27 byte header containing the Z80 registers
  void loadSNASnapshot(ByteData snapshot) {
    final r = snapshot.buffer.asUint8List(0, 27);

    spectrum.z80
      ..i = r[0]
      ..hl_ = createWord(r[1], r[2])
      ..de_ = createWord(r[3], r[4])
      ..bc_ = createWord(r[5], r[6])
      ..af_ = createWord(r[7], r[8])
      ..hl = createWord(r[9], r[10])
      ..de = createWord(r[11], r[12])
      ..bc = createWord(r[13], r[14])
      ..iy = createWord(r[15], r[16])
      ..ix = createWord(r[17], r[18])
      ..iff2 = isBitSet(r[19], 2)
      ..iff1 = isBitSet(r[19], 2)
      ..r = r[20]
      ..af = createWord(r[21], r[22])
      ..sp = createWord(r[23], r[24])
      ..im = r[25];
    spectrum.ula.screenBorder = r[26];

    spectrum.z80.memory.load(0x4000, snapshot.buffer.asUint8List(27));

    // The program counter is pushed onto the stack, and since SP points to
    // the stack, we can simply POP it off.
    spectrum.z80.pc = spectrum.z80.POP();
  }

  // Per http://rk.nvg.ntnu.no/sinclair/formats/z80-format.html
  // the snapshot format has a 30 byte header containing the Z80 registers
  void loadZ80Snapshot(ByteData snapshot) {
    var r = snapshot.buffer.asUint8List(0, 30);

    var fileFormatVersion = 145;
    var isDataBlockCompressed = false;
    var headerLength = 30;

    if (createWord(r[6], r[7]) == 0) {
      r = snapshot.buffer.asUint8List(0, 86);
      if (createWord(r[30], r[31]) == 54) {
        fileFormatVersion = 300;
        headerLength = 30 + 54 + 2;
      } else if (createWord(r[30], r[31]) == 23) {
        fileFormatVersion = 201;
        headerLength = 30 + 23 + 2;
      } else {
        throw Exception('Unrecognized Z80 file format.');
      }
    }

    z80.af = createWord(r[0], r[1]);
    z80.bc = createWord(r[2], r[3]);
    z80.hl = createWord(r[4], r[5]);
    if (fileFormatVersion <= 145) {
      z80.pc = createWord(r[6], r[7]);
    } else {
      z80.pc = createWord(r[32], r[33]);
    }
    z80.sp = createWord(r[8], r[9]);
    z80.i = r[10];
    z80.r = r[11];
    spectrum.ula.screenBorder = (r[12] << 1) & 0x03;
    if (isBitSet(r[12], 5)) {
      isDataBlockCompressed = true;
    }
    z80.de = createWord(r[13], r[14]);
    z80.bc_ = createWord(r[15], r[16]);
    z80.de_ = createWord(r[17], r[18]);
    z80.hl_ = createWord(r[19], r[20]);
    z80.af_ = createWord(r[21], r[22]);
    z80.iy = createWord(r[23], r[24]);
    z80.ix = createWord(r[25], r[26]);
    z80.iff1 = z80.iff2 = r[27] == 0;
    if ((r[29] & 0x03) == 0x00) {
      z80.im = 0;
    } else if ((r[29] & 0x03) == 0x01) {
      z80.im = 1;
    } else if ((r[29] & 0x03) == 0x02) {
      z80.im = 2;
    }

    final dataBlock = snapshot.buffer.asUint8List(headerLength);
    if (!isDataBlockCompressed) {
      z80.memory.load(0x4000, dataBlock);
    } else {
      z80.memory.load(0x4000, decodedCompressedZ80DataBlock(dataBlock));
    }
  }

  /// Decompress the body of a compressed Z80 file format.
  ///
  /// The compression mechanism is simple: repeated sequences of the same byte
  /// are stored using a run-length encoding algorithm. Other bytes are
  /// uncompressed.
  Uint8List decodedCompressedZ80DataBlock(Uint8List rawData) {
    final decoded = <int>[];
    var idx = 0;
    // Lists are not identical just because they contain the same elements.
    final listEquals = const ListEquality<int>().equals;

    // End marker for a compressed Z80 file is 00 ED ED 00. But
    // also compare against the end of file, since later file formats omit the end marker.
    while (!listEquals(rawData.sublist(idx), [0x00, 0xED, 0xED, 0x00]) &&
        idx < rawData.lengthInBytes) {
      if (rawData[idx] == 0xED && rawData[idx + 1] == 0xED) {
        // Compressed block starts here: ED ED xx yy indicates "byte yy repeated
        // xx times".
        final xx = rawData[idx + 2];
        final yy = rawData[idx + 3];

        decoded.addAll(List.generate(xx, (_) => yy));
        idx += 4;
      } else {
        // This byte is not compressed, so just add it
        decoded.add(rawData[idx++]);
      }
    }
    return Uint8List.fromList(decoded);
  }
}
