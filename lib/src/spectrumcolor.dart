// spectrumcolor.dart -- color system for ZX Spectrum

/// One of the pre-defined color values used by the ZX Spectrum.
enum SpectrumColor {
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
  white;

  /// Returns the RGB color represented by the underlying ZX Spectrum color.
  int get rgbColor {
    switch (this) {
      case SpectrumColor.black:
        return 0xFF000000;
      case SpectrumColor.blue:
        return 0xFF0000CD;
      case SpectrumColor.red:
        return 0xFFCD0000;
      case SpectrumColor.magenta:
        return 0xFFCD00CD;
      case SpectrumColor.green:
        return 0xFF00CD00;
      case SpectrumColor.cyan:
        return 0xFF00CDCD;
      case SpectrumColor.yellow:
        return 0xFFCDCD00;
      case SpectrumColor.gray:
        return 0xFFCDCDCD;
      case SpectrumColor.brightBlack:
        // This is really just black
        return 0xFF000000;
      case SpectrumColor.brightBlue:
        return 0xFF0000FF;
      case SpectrumColor.brightRed:
        return 0xFFFF0000;
      case SpectrumColor.brightMagenta:
        return 0xFFFF00FF;
      case SpectrumColor.brightGreen:
        return 0xFF00FF00;
      case SpectrumColor.brightCyan:
        return 0xFF00FFFF;
      case SpectrumColor.brightYellow:
        return 0xFFFFFF00;
      case SpectrumColor.white:
        return 0xFFFFFFFF;
    }
  }

  /// Takes a single byte value and returns the color represented by it.
  factory SpectrumColor.fromByteValue(int value) => SpectrumColor.values[value];

  /// The red channel of this color as an 8-bit value.
  int get redChannel => (0x00ff0000 & rgbColor) >> 16;

  /// The green channel of this color as an 8-bit value.
  int get greenChannel => (0x0000ff00 & rgbColor) >> 8;

  /// The blue channel of this color as an 8-bit value.
  int get blueChannel => (0x000000ff & rgbColor) >> 0;
}
