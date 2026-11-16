#!/usr/bin/env bash
# Fails when a tracked path breaks the naming rules in docs/NAMING.md:
# English, ASCII, no spaces, lowercase directories.
set -euo pipefail

failed=0

report() {
  printf '  ✗ %s — %s\n' "$1" "$2" >&2
  failed=1
}

while IFS= read -r path; do
  case "$path" in
    "" ) continue ;;
  esac

  if printf '%s' "$path" | LC_ALL=C grep -q '[^ -~]'; then
    report "$path" "caracteres no ASCII"
  fi

  case "$path" in
    *" "*) report "$path" "contiene espacios" ;;
  esac

  dirs="${path%/*}"
  if [ "$dirs" != "$path" ]; then
    IFS='/' read -r -a parts <<< "$dirs"
    for part in "${parts[@]}"; do
      case "$part" in
        ""|"."|"..") continue ;;
        # GitHub imposes this uppercase directory name; it is a framework exception.
        "ISSUE_TEMPLATE") continue ;;
      esac
      if printf '%s' "$part" | LC_ALL=C grep -q '[^a-z0-9._-]'; then
        report "$path" "directorio no conforme: $part"
      fi
    done
  fi
done < <(git ls-files)

if [ "$failed" -ne 0 ]; then
  echo "Naming check failed." >&2
  exit 1
fi

echo "Naming check passed."
