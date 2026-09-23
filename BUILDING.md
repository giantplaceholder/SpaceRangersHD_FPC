# Building

## Requirements

Build natively on Linux x86_64 or macOS ARM64. Linux ARM64 is recognized but unvalidated.
Requires Python 3.10+, FPC 3.2.2, GNU Make, CMake 3.20+, pkg-config, and development
libraries for SDL2 2.26+ (or SDL2-compat), libogg, libvorbis, libjpeg, and libpng.

- Linux: C11 compiler and binutils. LLVM builds also require `clang` and `ld.lld` (validated with 22.1.3).
- macOS: Xcode command-line tools and Homebrew.

AVI playback needs Xvid: `libxvidcore.so.4` on Linux, `xvidcore` on macOS.
`FPC_BOOTSTRAP` overrides the installed compiler used to bootstrap the pinned FPC.

## Build and run

```sh
git submodule update --init --recursive
./tools/build.py
./tools/run.py --game-dir=/path/to/game
```

The scripts detect the host OS; `--target=linux` or `--target=macos` selects it
explicitly. Resources default to `game/` when `--game-dir` is omitted.

- `--release`: `-O4` instead of the default `-O2`.
- `--llvm`: LLVM backend on Linux; macOS uses LLVM by default.
- `--lto`: Pascal link-time optimization, implying LLVM; unavailable on Android.
- `--rebuild`: rebuild all game units and native code (build script only).

Use matching `--release`, `--llvm`, and `--lto` options for build and run.
Profiles are `debug` or `release`, followed by `-llvm` for Linux LLVM builds
and `-lto` when enabled. Compiler/RTL caches live in `.local/fpc/`.

| Platform | Output |
| --- | --- |
| Linux | `.local/linux-<cpu>/<profile>/bin/`: `Rangers` and `libokgf.so` |
| macOS | `.local/<profile>/Space Rangers HD.app` |

Linux CPU names are `x86_64` and `aarch64`. Keep the Linux executable and OKGF
library together; SDL and codecs remain system dependencies.

## Formatting

Pascal source uses [pasfmt](https://github.com/integrated-application-development/pasfmt)
with `pasfmt.toml`. `tools/format.py` also uses clang-format, Ruff,
cmake-format, and xmllint.

```sh
./tools/format.py
./tools/format.py --check
```
