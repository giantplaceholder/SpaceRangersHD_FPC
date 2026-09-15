# Building

## macOS ARM64

Requires Python 3, FPC 3.2.2 for bootstrapping, GNU Make,
Xcode command-line tools, CMake, pkg-config, SDL2, SDL2_mixer, libjpeg, and libpng.
`FPC_BOOTSTRAP` selects the installed bootstrap compiler.

```sh
git submodule update --init --recursive
./tools/build.py
./tools/run.py --game-dir=/path/to/game
```

The build script bootstraps the pinned FPC LLVM compiler into `.local/fpc/`.
Use `--release` with both build and run scripts for release settings.
`./tools/build.py --rebuild` forces a game rebuild.

Game resources default to the ignored `game/` directory. `--game-dir` selects
another location. Build output is stored under `.local/`.

## Formatting

Pascal source uses [pasfmt](https://github.com/integrated-application-development/pasfmt)
with `pasfmt.toml`. `tools/format.py` also uses clang-format, Ruff,
cmake-format, and xmllint.

```sh
./tools/format.py
./tools/format.py --check
```
