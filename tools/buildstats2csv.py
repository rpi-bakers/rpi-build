import argparse
import csv
import os
import re
from typing import Iterable, List, Optional, Tuple
from datetime import datetime


ELAPSED_PATTERNS = [
    re.compile(r"^\s*Elapsed\s*time\s*[:=]\s*(.+?)\s*$", re.IGNORECASE),
]


def parse_time_to_seconds(text: str) -> Optional[float]:
    """Parse 'Elapsed time: xx.xx seconds' formats into seconds.
    Returns seconds as float, or None if parsing fails.
    """
    text = text.strip().lower()
    # Try simple seconds
    m = re.match(r"^([\d.]+)\s*seconds?$", text)
    if m:
        try:
            return float(m.group(1))
        except ValueError:
            return None

def find_elapsed_in_file(file_path: str) -> List[Optional[float]]:
    """Scan a file and return list of tuples (seconds or None)."""
    results: List[Optional[float]] = []
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                for pat in ELAPSED_PATTERNS:
                    m = pat.search(line)
                    if m:
                        raw = m.group(1).strip()
                        sec = parse_time_to_seconds(raw)
                        results.append(sec)
                        break
    except (OSError, UnicodeError):
        # Skip unreadable files
        return results
    return results


def iter_files(root: str) -> Iterable[str]:
    for dirpath, dirnames, filenames in os.walk(root):
        for fn in filenames:
            yield os.path.join(dirpath, fn)


def rel_to_recipe(buildstats_root: str, file_path: str) -> Tuple[str, str]:
    """Return (recipe_dir, relative_path_from_recipe) for a given file path.

    If the file is not inside a recipe directory directly under buildstats_root,
    recipe_dir is "" and relative_path is path relative to buildstats_root.
    """
    abs_root = os.path.abspath(buildstats_root)
    abs_file = os.path.abspath(file_path)
    rel = os.path.relpath(abs_file, abs_root)
    parts = rel.split(os.sep)
    if len(parts) >= 2:
        ts = parts[0]
        rel_from_ts = os.path.join(*parts[1:])
        return ts, rel_from_ts
    return "", rel


def collect_elapsed(buildstats_root: str) -> List[dict]:
    rows: List[dict] = []
    prev_recipe = "-----"
    sec_total = 0.0
    for path in iter_files(buildstats_root):
        print(f"Scanning file: {path}")
        matches = find_elapsed_in_file(path)
        if not matches:
            continue
        ts, rel = rel_to_recipe(buildstats_root, path)
        for sec in matches:
            rows.append({
                'recipe': ts,
                'file': rel,
                'elapsed_seconds': format_hms(sec) if sec is not None else "",
            })
            if prev_recipe != "-----" and prev_recipe != ts:
                rows.append({
                    'recipe': prev_recipe,
                    'file': "=====Total=====",
                    'elapsed_seconds': format_hms(sec_total) if sec_total is not None else "",
                })
                # New recipe group
                sec_total = sec if sec is not None else 0.0
            else:
                sec_total += sec if sec is not None else 0.0
            prev_recipe = ts
    # Sort: recipe, file
    rows.sort(key=lambda r: (r['recipe'], r['file']))
    return rows

def format_hms(seconds: Optional[float]) -> str:
    if seconds is None:
        return ""
    total = int(round(seconds))
    h = total // 3600
    m = (total % 3600) // 60
    s = total % 60
    return f"{h:02d}:{m:02d}:{s:02d}"

def write_csv(rows: List[dict], out_path: str) -> None:
    fieldnames = ['recipe', 'file', 'elapsed_seconds']
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def default_buildstats_dir() -> str:
    """Return the latest dated buildstats directory.

    If BUILDDIR is set in the environment (e.g. from env.sh), use
    "$BUILDDIR/tmp/buildstats" as the base. Otherwise, fall back to
    "../tmp/buildstats" relative to this script. Under that base, look
    for date-like subdirectories (e.g. 20251228-...) and pick the
    lexicographically last one. If no suitable subdirectory exists,
    return the base directory itself.
    """

    # Prefer BUILDDIR from the environment if available
    build_dir_env = os.environ.get("BUILDDIR")
    if build_dir_env:
        base = os.path.normpath(os.path.join(os.path.abspath(build_dir_env), 'tmp', 'buildstats'))
    else:
        here = os.path.dirname(os.path.abspath(__file__))
        base = os.path.normpath(os.path.join(here, '..', 'tmp', 'buildstats'))

    try:
        entries = [
            d for d in os.listdir(base)
            if os.path.isdir(os.path.join(base, d))
        ]
    except OSError:
        # If the buildstats directory itself does not exist, just return it
        return base

    if not entries:
        return base

    # Prefer directory names that look like dates (first 8 chars are digits)
    date_like = [d for d in entries if re.match(r"^\d{8}", d)]
    candidates = date_like or entries
    latest = sorted(candidates)[-1]
    return os.path.join(base, latest)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description='Collect "Elapsed time" from Yocto buildstats into CSV.')
    parser.add_argument('-i', '--input', dest='buildstats_dir', default=None,
                        help='Path to buildstats directory (default: derived from BUILDDIR/tmp/buildstats)')
    parser.add_argument('-o', '--output', dest='output_csv', default=None,
                        help='Output CSV path (default: <buildstats_dir>/elapsed_times.csv)')
    args = parser.parse_args(argv)

    # Determine buildstats directory. If the user did not explicitly
    # specify -i/--input and BUILDDIR is not set, instruct them to
    # source setup.sh (which in turn sources env.sh) and exit.
    if args.buildstats_dir:
        buildstats_dir = os.path.abspath(args.buildstats_dir)
    else:
        if not os.environ.get("BUILDDIR"):
            print("ERROR: BUILDDIR is not set in the environment.")
            print("       Please run 'source setup.sh' in the rpi-build directory,")
            print("       or pass -i/--input explicitly to specify a buildstats directory.")
            print()
            parser.print_help()
            return 1
        buildstats_dir = os.path.abspath(default_buildstats_dir())
    if not os.path.isdir(buildstats_dir):
        print(f"ERROR: buildstats directory not found: {buildstats_dir}")
        return 1

    # Show which directory will be scanned
    print(f"Scanning buildstats directory: {buildstats_dir}")

    output_csv = args.output_csv
    if not output_csv:
        output_csv = os.path.join(buildstats_dir, f'../elapsed_times{datetime.now().strftime("_%Y%m%d_%H%M%S")}.csv')
    else:
        output_csv = os.path.abspath(output_csv)

    rows = collect_elapsed(buildstats_dir)
    write_csv(rows, output_csv)
    print(f"Collected {len(rows)} entries -> {output_csv}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
