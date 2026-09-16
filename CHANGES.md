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
- Replace VCL/Win32 windowing, input, cursors, clipboard and document opening
  with direct Pascal SDL2 calls. Preserve game message/key values and map window
  coordinates through the displayed game viewport, including high-DPI scaling.
- Back the existing drawing and sound interfaces with SDL2. Keep CPU pixel
  access, render targets, gamma ramps, PCM streaming and position notifications.
  Native drivers receive the game's floating-point exception mask before startup.
- Run workers through FPC threads and preserve multi-event waits with SDL
  condition variables. Transfer worker failures to the caller before publishing
  completion; retain cache completion events and entries while callers wait.
- Rescale cached backgrounds with Pascal bilinear interpolation, retaining crop
  alignment and pixel-center sampling without using SDL rendering on workers.
- Retain music playback events across tracks, and make script-dialog waits
  respond to calculation shutdown before releasing their UI and script state.
- Decode Vorbis through FPC's native ABI declarations and encode JPEG screenshots
  through FPC's Pascal image package. Read AVI frame chunks in Pascal and use
  native Xvid decoding, replacing Video for Windows.
- Use FPC file enumeration, timestamps, Unicode case conversion and OS-specific
  user directories. Normalize filesystem paths separately from package keys and
  consistently use `Save` for save files, including their temporary output.
- Preserve Windows' case-insensitive file matching for installed languages,
  mod language resources, saves and robot maps. Keep the current language when
  the settings screen has no language choices, instead of saving an empty code.
- Replace timestamp-counter CPU probes with OS queries and the original fallback;
  use native memory queries for physical memory and FPC heap usage on Unix.
- Keep legacy script DLL calls and the original Steam/MatrixGame wrappers limited
  to 32-bit Windows. Their interfaces and original DLL integrity checks describe
  that distribution, not the native libraries used by other targets.
- Make Delphi's coordinate-list float bit casts and signed seed arithmetic
  explicit. Disambiguate the game's point type from FPC's `Types.TPointF`.
- Advance the text-wrapping scan explicitly instead of relying on Delphi's
  exhausted `for` counter, which otherwise stalls on the final character in FPC.
- Declare C record-pointer arguments with `constref`, preserving the original
  OKGF clipping-rectangle ABI and SDL's message-box data pointer across targets.
- Share SDL's logical window resolution between presentation and mouse events.
  Query the desktop cursor for window-leave handling where supported, and refresh
  the game cursor on re-entry instead of retaining a stale position at the edge.
  Refresh native cursor visibility on focus return, applying AppKit's current
  cursor immediately on macOS when the pointer stays inside the game window.
- Preserve native object addresses through script integer cells, references,
  decimal strings, cross-script arguments and array lookup. Keep signed `int`
  arithmetic and serialized script scalar fields at 32 bits.
- Widen dialog, timer and UI payloads, film object handles and GAI frame-cache
  entries to the host pointer size. Size in-memory film command overlays for
  their pointer fields while retaining the original serialized film layout.
- Address ship equipment and score counters through their fields instead of
  fixed Win32 object offsets; allocate storage records by their actual size.
  Preserve the full encoded player pointer and pointer fields excluded from
  in-memory state protection.
