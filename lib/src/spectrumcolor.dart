// spectrumcolor.dart -- color system for ZX Spectrum

// Based on Color from dart:ui, and values are compatible with Color, but
// assumes alpha channel is always opaque (since ZX Spectrum has no concept
// of transparency).

class SpectrumColor {
  final int rgbColor;

  const SpectrumColor(this.rgbColor);

  /// Takes a single byte value and returns the color represented by it.
  factory SpectrumColor.fromByteValue(int value) =>
      SpectrumColor(_spectrumColors[value]!);

  factory SpectrumColor.fromName(SpectrumColors value) =>
      SpectrumColor(_spectrumColors[value.index]!);

  /// The red channel of this color in an 8 bit value.
  int get red => (0x00ff0000 & rgbColor) >> 16;

  /// The green channel of this color in an 8 bit value.
  int get green => (0x0000ff00 & rgbColor) >> 8;

  /// The blue channel of this color in an 8 bit value.
  int get blue => (0x000000ff & rgbColor) >> 0;

  @override
  String toString() =>
      "SpectrumColor(0x${(rgbColor & 0x00FFFFFF).toRadixString(16).padLeft(6, '0')})";
}

const _spectrumColors = <int, int>{
  0x00: 0xFF000000, // black
  0x01: 0xFF0000CD, // blue
  0x02: 0xFFCD0000, // red
  0x03: 0xFFCD00CD, // magenta
  0x04: 0xFF00CD00, // green
  0x05: 0xFF00CDCD, // cyan
  0x06: 0xFFCDCD00, // yellow
  0x07: 0xFFCDCDCD, // gray
  0x08: 0xFF000000, // black
  0x09: 0xFF0000FF, // bright blue
  0x0A: 0xFFFF0000, // bright red
  0x0B: 0xFFFF00FF, // bright magenta
  0x0C: 0xFF00FF00, // bright green
  0x0D: 0xFF00FFFF, // bright cyan
  0x0E: 0xFFFFFF00, // bright yellow
  0x0F: 0xFFFFFFFF, // white
};

enum SpectrumColors {
  black,
  blue,
  red,
  magenta,
  green,
  cyan,
  yellow,
  gray,
  brightBlack,
  brightBlue,
  brightRed,
  brightMagenta,
  brightGreen,
  brightCyan,
  brightYellow,
  white
}
