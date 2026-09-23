"""Shared desktop target and artifact selection for build and run."""

import platform
from pathlib import Path


def desktop_target() -> str:
    return "linux" if platform.system() == "Linux" else "macos"


def linux_cpu() -> str:
    if platform.system() != "Linux":
        raise RuntimeError("Linux builds currently require a native Linux host.")
    machine = platform.machine().lower()
    aliases = {"amd64": "x86_64", "arm64": "aarch64"}
    cpu = aliases.get(machine, machine)
    if cpu not in ("x86_64", "aarch64"):
        raise RuntimeError(f"Unsupported Linux architecture: {machine}")
    return cpu


def desktop_directory(
    root: Path, target: str, release: bool, lto: bool = False, *, llvm: bool = False
) -> Path:
    configuration = "release" if release else "debug"
    if target == "linux" and (llvm or lto):
        configuration += "-llvm"
    configuration += "-lto" if lto else ""
    if target == "linux":
        return root / ".local" / f"linux-{linux_cpu()}" / configuration
    return root / ".local" / configuration


def desktop_binary(
    root: Path, target: str, release: bool, lto: bool = False, *, llvm: bool = False
) -> Path:
    directory = desktop_directory(root, target, release, lto, llvm=llvm)
    if target == "linux":
        return directory / "bin/Rangers"
    return directory / "Space Rangers HD.app/Contents/MacOS/Rangers"
