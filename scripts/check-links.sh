#!/usr/bin/env bash
# Verifica que los enlaces internos de la documentación resuelven.
# Los enlaces externos no se comprueban (red y terceros cambian).
set -euo pipefail

python3 - <<'PY'
import pathlib
import re
import sys

ROOT = pathlib.Path(".").resolve()
SKIP_DIRS = {".git", "node_modules", ".next", "out", "cache", "lib", ".buildx"}

files = [
    path
    for path in ROOT.rglob("*.md")
    if not SKIP_DIRS.intersection(path.relative_to(ROOT).parts)
]

pattern = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
errors = []

for path in sorted(files):
    text = path.read_text(encoding="utf-8")
    for match in pattern.finditer(text):
        target = match.group(1)
        if target.startswith(("http://", "https://", "mailto:", "tel:", "#")):
            continue
        relative = target.split("#", 1)[0]
        if not relative:
            continue
        resolved = (path.parent / relative).resolve()
        if not resolved.exists():
            line = text[: match.start()].count("\n") + 1
            errors.append(f"{path.relative_to(ROOT)}:{line}: {target}")

for error in errors:
    print(f"enlace roto: {error}", file=sys.stderr)

if errors:
    print(f"\n{len(errors)} enlace(s) roto(s).", file=sys.stderr)
    sys.exit(1)

print(f"Enlaces internos OK ({len(files)} archivos Markdown).")
PY
