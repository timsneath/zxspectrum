# ZX Spectrum emulator

A simple ZX Spectrum emulator, originally built with UWP and C# before being
ported to Flutter and Dart.

More at:
   <https://twitter.com/timsneath/status/1345088320313774080>

The Z80 core passes the FUSE test suite, which contains 1356 tests that evaluate
the correctness of both documented and undocumented instructions.

Functional enough to be able to boot the supplied ZX Spectrum 48K image and
accept keyboard input, as well as load various applications in SNA or ROM
format.

API is not stable yet.
