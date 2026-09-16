# Space Rangers HD — Free Pascal Port

A Free Pascal port of **Space Rangers HD: A War Apart**, based on the
recovered Delphi source and intended to preserve the original game behavior.

The source was generated from
[SpaceRangersHD_decomp at `2082a83`](https://github.com/pakompom/SpaceRangersHD_decomp/tree/2082a833b19465e625d81e8fbb0c7c98ab58ebf6),
which reconstructs the **2026-08-11 prerelease** build.

## Layout

- `source/`: game source, organized by subsystem.
- `tools/`: build, run, compiler bootstrap, and formatting scripts.
- `platform/`: Pascal windowing, input, graphics, audio, and OS services.
- `native/`: OKGF build integration.
- `vendor/okgf/`: pinned [OKGF](https://github.com/pakompom/okgf) submodule.
- `vendor/fpc/`: pinned [FPC fork](https://github.com/pakompom/fpc_sr) submodule.

## Documentation

- [Build setup](BUILDING.md)
- [Delphi-to-FPC changes](CHANGES.md)
- [Attribution](NOTICE.md) and [license](LICENSE)
- [Personal branch with enhancements](https://github.com/pakompom/SpaceRangersHD_FPC/tree/personal)

Development uses LLMs such as GPT-6 Astra through Codex.
