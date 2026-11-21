#!/usr/bin/env python3
"""
build.py - regenerates mod.yml.

Usage:
  python build.py
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent


def main():
    gen_yml = subprocess.run([sys.executable, str(ROOT / 'generate_mod_yml.py')])
    sys.exit(gen_yml.returncode)


if __name__ == '__main__':
    main()
