# Delphi-to-FPC changes

This changelog records game-source changes for Free Pascal compatibility.

- Replace x86 assembly in memory access, CRC, rectangle intersection, UTF-16
  comparisons, buffer reads, script arrays, geometry and saved-pixel restoration
  with Pascal. Preserve fixed-width buffer values and native comparison results.
- Allocate game memory through FPC on Windows, Linux and macOS. Private heaps
  retain bulk destruction; their handles follow the host pointer width.
- Use FPC file I/O for packages and loose files, converting path separators at
  the filesystem boundary. Keep package directory entries at 158 bytes on disk
  while allowing native-sized pointers in memory.
- Decode ZL02 package blocks through FPC's Pascal zlib implementation, retaining
  the original DLL's header and decoded-length checks.
- Initialize the FPC thread and wide-string managers on Unix targets.
