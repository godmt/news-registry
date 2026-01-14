import json
import sys
from pathlib import Path

def validate_jsonl(path: Path) -> int:
    bad = 0
    for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = line.strip()
        if not line:
            continue
        try:
            json.loads(line)
        except Exception as e:
            bad += 1
            print(f"[ERROR] {path}:{i} {e}", file=sys.stderr)
    return bad

def main() -> int:
    root = Path(__file__).resolve().parents[1]
    bad = 0
    for p in (root / "sources").glob("*.jsonl"):
        bad += validate_jsonl(p)
    # tags.json must be valid JSON
    try:
        json.loads((root / "taxonomy" / "tags.json").read_text(encoding="utf-8"))
    except Exception as e:
        bad += 1
        print(f"[ERROR] taxonomy/tags.json {e}", file=sys.stderr)
        # manifest.json must be valid JSON
    try:
        json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    except Exception as e:
        bad += 1
        print(f"[ERROR] manifest.json {e}", file=sys.stderr)


    if bad:
        print(f"Validation failed: {bad} error(s)", file=sys.stderr)
        return 1
    print("OK")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
