"""Bootstrap the pinned FPC compiler and isolated platform runtimes."""

import hashlib
import os
import shutil
import subprocess
from pathlib import Path

from targets import linux_cpu

ROOT = Path(__file__).resolve().parents[1]
VENDOR = ROOT / "vendor/fpc"
WORK = ROOT / ".local/fpc"
SOURCE = WORK / "source"
LLVM_FLAGS = ("-Clv17.0",)


def source_revision() -> str:
    """Invalidate generated compilers when their source or build recipe changes."""
    digest = hashlib.sha256(Path(__file__).read_bytes())
    for path in sorted(VENDOR.rglob("*")):
        # A submodule's .git file describes its checkout, not compiler inputs.
        if ".git" in path.relative_to(VENDOR).parts:
            continue
        if path.is_file() and path.suffix not in (".md", ".txt"):
            digest.update(str(path.relative_to(VENDOR)).encode())
            digest.update(path.read_bytes())
    return digest.hexdigest()


def matches(path: Path, revision: str) -> bool:
    return path.is_file() and path.read_text() == revision


def prepare_compiler(
    target: str, run_step, toolchain: Path | None = None, *, lto: bool = False, llvm: bool = False
) -> tuple[Path, list[str]]:
    """Bootstrap isolated native/LLVM compilers and matching target runtimes."""
    if lto and target not in ("linux", "macos"):
        raise ValueError("LTO is currently supported only for Linux and macOS builds.")
    llvm = llvm or lto or target != "linux"
    if not (VENDOR / "compiler/pp.pas").is_file():
        raise FileNotFoundError(
            "Initialize dependencies with: git submodule update --init --recursive"
        )
    cpu = linux_cpu() if target == "linux" else "aarch64"
    system = {"linux": "linux", "macos": "darwin", "android": "android"}[target]
    work = WORK / f"{cpu}-linux" if target == "linux" else WORK
    if target == "linux" and llvm:
        work = work.with_name(work.name + "-llvm")
    source = work / "source" if target == "linux" else SOURCE
    llvm_flags = LLVM_FLAGS if llvm else ()
    if target == "linux" and llvm:
        llvm_flags += ("-Aclang-llvm",)
    sdk = None
    if target != "linux":
        sdk = subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()
    make = shutil.which("gmake") or shutil.which("make")
    if make is None:
        raise FileNotFoundError("Install GNU Make to build the vendored compiler.")
    revision = source_revision()
    work.mkdir(parents=True, exist_ok=True)
    compiler = source / "compiler" / ("ppcx64" if cpu == "x86_64" else "ppca64")
    stamp = work / "compiler.stamp"
    if not compiler.is_file() or not matches(stamp, revision):
        bootstrap = shutil.which(os.environ.get("FPC_BOOTSTRAP", "fpc"))
        if bootstrap is None:
            raise FileNotFoundError("Install FPC 3.2.2 to bootstrap the vendored compiler.")
        stamp.unlink(missing_ok=True)
        if source.exists():
            shutil.rmtree(source)
        shutil.copytree(VENDOR, source, ignore=shutil.ignore_patterns(".git"))
        run_step(work, "compiler", [
            make, "-C", source, "compiler_cycle", "NOWPOCYCLE=1",
            f"PP={bootstrap}", "OPT=-O2" + (f" -XR{sdk}" if sdk else ""),
            *(["LLVM=1", "OPTNEW=" + " ".join(llvm_flags)] if llvm_flags else []),
        ])  # fmt: skip
        stamp.write_text(revision)

    runtime = work / "runtime" / (f"{cpu}-{system}" + ("-lto" if lto else ""))
    runtime_source = runtime / "src"
    units = runtime_source / "rtl/units" / f"{cpu}-{system}"
    options = ["-O2", *llvm_flags, "-dCLASSESINLINE"]
    if target == "android":
        if toolchain is None:
            raise RuntimeError("Android runtime compilation requires the NDK.")
        options += ["-Cg", "-Aclang-llvm", "-XP"]
        target_flags = [
            "CPU_TARGET=aarch64",
            "OS_TARGET=android",
            "BINUTILSPREFIX=",
            f"CROSSBINDIR={toolchain}",
        ]
    elif target == "macos":
        options += ["-Aclang-llvm-darwin", f"-XR{sdk}"]
        target_flags = []
    else:
        target_flags = [f"CPU_TARGET={cpu}", "OS_TARGET=linux"]
    if lto:
        options.append("-Clflto")
    stamp = runtime / "runtime.stamp"
    runtime_revision = revision + repr((options, target_flags))
    if not (units / "classes.ppu").is_file() or not matches(stamp, runtime_revision):
        runtime.mkdir(parents=True, exist_ok=True)
        stamp.unlink(missing_ok=True)
        if runtime_source.exists():
            shutil.rmtree(runtime_source)
        # Do not alter the native RTL used to bootstrap the compiler. Each
        # runtime profile starts from source and gets its own PPUs/objects.
        shutil.copytree(
            source / "rtl", runtime_source / "rtl", ignore=shutil.ignore_patterns("units")
        )
        for name in ("compiler", "packages"):
            (runtime_source / name).symlink_to(source / name, target_is_directory=True)
        units.mkdir(parents=True, exist_ok=True)
        if target == "android":
            for loader in ("prt0", "dllprt0"):
                run_step(runtime, loader, [
                    toolchain / "clang", "--target=aarch64-linux-android26", "-c",
                    "-x", "assembler", "-Wa,-defsym,CPU64=1",
                    runtime_source / f"rtl/android/{loader}.as", "-o", units / f"{loader}.o",
                ])  # fmt: skip
        run_step(runtime, "runtime", [
            make, "-C", runtime_source / "rtl", "all", *target_flags,
            f"FPC={compiler}", "OPT=" + " ".join(options),
        ])  # fmt: skip
        stamp.write_text(runtime_revision)

    packages = VENDOR / "packages"
    paths = [
        units,
        packages / "rtl-objpas/src/inc",
        packages / "fcl-base/src",
        packages / "pthreads/src",
        packages / "fcl-process/src",
    ]
    return compiler, [
        "-n", *llvm_flags, *(["-Clflto"] if lto else []),
        *(["-XLL"] if target == "linux" and llvm else []),
        *(f"-Fu{path}" for path in paths),
        f"-Fi{packages}/fcl-process/src/unix",
    ]  # fmt: skip
