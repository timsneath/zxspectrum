import 'dart:io';
import 'dart:ffi';

import 'package:dart_z80/dart_z80.dart';
import 'package:zxspectrum/zxspectrum.dart';

class AllContext {
  final Context ffiContext;
  final Context dartContext;

  const AllContext(this.ffiContext, this.dartContext);

  @override
  String toString() => 'ffi: $ffiContext\ndart: $dartContext';
}

class Context {
  int af = 0, bc = 0, de = 0, hl = 0, ix = 0, iy = 0;
  int af_ = 0, bc_ = 0, de_ = 0, hl_ = 0;
  int sp = 0, pc = 0;
  int im = 0;
  int iff1 = 0, iff2 = 0;

  @override
  String toString() => '[${pc.toRadixString(16)}] '
      '${af.toRadixString(16)} '
      '${bc.toRadixString(16)} '
      '${de.toRadixString(16)} '
      '${hl.toRadixString(16)} '
      '${ix.toRadixString(16)} '
      '${iy.toRadixString(16)} '
      '${af_.toRadixString(16)} '
      '${bc_.toRadixString(16)} '
      '${de_.toRadixString(16)} '
      '${hl_.toRadixString(16)} '
      '${sp.toRadixString(16)} '
      '${im.toRadixString(16)} '
      '${iff1.toRadixString(16)} '
      '${iff2.toRadixString(16)} ';
}

AllContext saveContext(Spectrum dartSpeccy) {
  final ffiContext = Context();
  final dartContext = Context();

  ffiContext
    ..af = ffiSpeccy.ctx.ref.R1.wr.AF
    ..bc = ffiSpeccy.ctx.ref.R1.wr.BC
    ..de = ffiSpeccy.ctx.ref.R1.wr.DE
    ..hl = ffiSpeccy.ctx.ref.R1.wr.HL
    ..ix = ffiSpeccy.ctx.ref.R1.wr.IX
    ..iy = ffiSpeccy.ctx.ref.R1.wr.IY
    ..af_ = ffiSpeccy.ctx.ref.R2.wr.AF
    ..bc_ = ffiSpeccy.ctx.ref.R2.wr.BC
    ..de_ = ffiSpeccy.ctx.ref.R2.wr.DE
    ..hl_ = ffiSpeccy.ctx.ref.R2.wr.HL
    ..sp = ffiSpeccy.ctx.ref.R1.wr.SP
    ..pc = ffiSpeccy.ctx.ref.PC
    ..im = ffiSpeccy.ctx.ref.IM
    ..iff1 = ffiSpeccy.ctx.ref.IFF1
    ..iff2 = ffiSpeccy.ctx.ref.IFF2;

  dartContext
    ..af = dartSpeccy.z80.af
    ..bc = dartSpeccy.z80.bc
    ..de = dartSpeccy.z80.de
    ..hl = dartSpeccy.z80.hl
    ..ix = dartSpeccy.z80.ix
    ..iy = dartSpeccy.z80.iy
    ..af_ = dartSpeccy.z80.af_
    ..bc_ = dartSpeccy.z80.bc_
    ..de_ = dartSpeccy.z80.de_
    ..hl_ = dartSpeccy.z80.hl_
    ..sp = dartSpeccy.z80.sp
    ..pc = dartSpeccy.z80.pc
    ..im = dartSpeccy.z80.im
    ..iff1 = dartSpeccy.z80.iff1 ? 1 : 0
    ..iff2 = dartSpeccy.z80.iff2 ? 1 : 0;

  return AllContext(ffiContext, dartContext);
}

void resetMachines(Spectrum dartSpeccy) {
  ffiSpeccy.reset();
  dartSpeccy.reset();
  ffiSpeccy.ctx.ref.R1.wr.AF = 0xFFFF;
  ffiSpeccy.ctx.ref.R1.wr.BC = 0xFFFF;
  ffiSpeccy.ctx.ref.R1.wr.DE = 0xFFFF;
  ffiSpeccy.ctx.ref.R1.wr.HL = 0xFFFF;
  ffiSpeccy.ctx.ref.R1.wr.IX = 0xFFFF;
  ffiSpeccy.ctx.ref.R1.wr.IY = 0xFFFF;
  ffiSpeccy.ctx.ref.R2.wr.AF = 0xFFFF;
  ffiSpeccy.ctx.ref.R2.wr.BC = 0xFFFF;
  ffiSpeccy.ctx.ref.R2.wr.DE = 0xFFFF;
  ffiSpeccy.ctx.ref.R2.wr.HL = 0xFFFF;
  ffiSpeccy.ctx.ref.R2.wr.IX = 0xFFFF;
  ffiSpeccy.ctx.ref.R2.wr.IY = 0xFFFF;
}

bool compareRegister(int i, int pc, String reg, int ffiValue, int dartValue) {
  if (ffiValue != dartValue) {
    print('\n[$i] At ${pc.toRadixString(16)}, $reg is different between '
        'FFI (${ffiValue.toRadixString(16)}) and '
        'Dart(${dartValue.toRadixString(16)})');

    print(Disassembler.disassembleMultipleInstructions(
        romFile.sublist(pc), 4, pc));
    return true;
  }
  return false;
}

void compareSpectrums(int i, SpectrumFFI ffiSpeccy, Spectrum dartSpeccy) {
  final pc = ffiSpeccy.ctx.ref.PC;
  bool error = false;
  error |= compareRegister(
      i, pc, 'af', ffiSpeccy.ctx.ref.R1.wr.AF, dartSpeccy.z80.af);
  error |= compareRegister(
      i, pc, 'bc', ffiSpeccy.ctx.ref.R1.wr.BC, dartSpeccy.z80.bc);
  error |= compareRegister(
      i, pc, 'de', ffiSpeccy.ctx.ref.R1.wr.DE, dartSpeccy.z80.de);
  error |= compareRegister(
      i, pc, 'hl', ffiSpeccy.ctx.ref.R1.wr.HL, dartSpeccy.z80.hl);
  error |= compareRegister(
      i, pc, 'ix', ffiSpeccy.ctx.ref.R1.wr.IX, dartSpeccy.z80.ix);
  error |= compareRegister(
      i, pc, 'iy', ffiSpeccy.ctx.ref.R1.wr.IY, dartSpeccy.z80.iy);

  error |= compareRegister(
      i, pc, "af'", ffiSpeccy.ctx.ref.R2.wr.AF, dartSpeccy.z80.af_);
  error |= compareRegister(
      i, pc, "bc'", ffiSpeccy.ctx.ref.R2.wr.BC, dartSpeccy.z80.bc_);
  error |= compareRegister(
      i, pc, "de'", ffiSpeccy.ctx.ref.R2.wr.DE, dartSpeccy.z80.de_);
  error |= compareRegister(
      i, pc, "hl'", ffiSpeccy.ctx.ref.R2.wr.HL, dartSpeccy.z80.hl_);

  if (error) {
    print('Old Context:\n$oldContext\nNew Context:\n$newContext');
    exit(1);
  }
}

final romFile = File('roms/48.rom').readAsBytesSync();
late AllContext oldContext, newContext;

void main() {
  final dartSpeccy = Spectrum(romFile);
  resetMachines(dartSpeccy);

  compareSpectrums(0, ffiSpeccy, dartSpeccy);

  var i = 0;
  while (true) {
    if (i % 100000 == 0) stdout.write('.');
    i++;

    oldContext = saveContext(dartSpeccy);
    ffiSpeccy.z80b.Z80Execute(ffiSpeccy.ctx);
    dartSpeccy.z80.executeNextInstruction();
    newContext = saveContext(dartSpeccy);

    compareSpectrums(i, ffiSpeccy, dartSpeccy);
  }
}
