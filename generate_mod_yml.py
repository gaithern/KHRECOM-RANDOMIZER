#!/usr/bin/env python3
"""Generate mod.yml from all files in the mod/ directory."""

from pathlib import Path

HEADER = """\
title: KHRECOM Randomizer Core
originalAuthor: Gicu
description: RE:Chain of Memories Archipelago Randomizer Mod.  Requires KHRECOM-LUA-LIBRARY.
assets:
"""

MOD_DIR = Path(__file__).parent / "mod"
OUTPUT = Path(__file__).parent / "mod.yml"


def relative_posix(path: Path) -> str:
    return path.relative_to(MOD_DIR).as_posix()


def main():
    if not MOD_DIR.exists():
        print(f"Error: mod/ directory not found at {MOD_DIR}")
        return

    files = sorted(f for f in MOD_DIR.rglob("*") if f.is_file())

    if not files:
        print("No files found in mod/")
        return

    lines = [HEADER]
    for f in files:
        rel = relative_posix(f)
        lines.append(f"- name: {rel}\n  method: copy\n  source:\n  - name: mod/{rel}\n")

    OUTPUT.write_text("".join(lines), encoding="utf-8")
    print(f"Generated {OUTPUT} with {len(files)} entries.")


if __name__ == "__main__":
    main()
