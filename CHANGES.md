# Delphi-to-FPC changes

This changelog records game-source changes for Free Pascal compatibility.

- Replace x86 assembly in memory access, CRC, rectangle intersection, UTF-16
  comparisons, buffer reads, script arrays, geometry and saved-pixel restoration
  with Pascal. Preserve fixed-width buffer values and native comparison results.
- Replace graphics and font assembly with Pascal, retaining lookup-table color
  rounding, forward overlapping copies, RGB565/RGB555 blending and saturated
  alpha addition. Empty pixel loops no longer wrap their counters and overrun
  buffers; the original line-drawing register corruption is not reproduced.
- Configure floating-point exceptions, rounding and x87 precision through FPC's
  `Math` unit in the renderer and calculation threads. CPUs without selectable
  precision use their native precision.
- Allocate game memory through FPC on Windows, Linux and macOS. Private heaps
  retain bulk destruction; their handles follow the host pointer width.
- Use FPC file I/O for packages and loose files, converting path separators at
  the filesystem boundary. Keep package directory entries at 158 bytes on disk
  while allowing native-sized pointers in memory.
- Decode ZL02 package blocks through FPC's Pascal zlib implementation, retaining
  the original DLL's header and decoded-length checks.
- Encode and decode ZL01 buffers through Pascal zlib, retaining the original
  compression levels, size limit and header-only size query. The buffer format
  remains unchanged.
- Initialize the FPC thread and wide-string managers on Unix targets.
