"""Forensic audit of theme assets — read-only."""
from __future__ import annotations

import hashlib
from collections import defaultdict
from pathlib import Path

from PIL import Image

ROOT = Path(r"e:/~Work/Birthday/assets")


def main() -> None:
    rows: list[dict] = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(ROOT).as_posix()
        size = path.stat().st_size
        ext = path.suffix.lower()
        info: dict = {"path": rel, "bytes": size, "ext": ext}
        if ext in {".png", ".jpg", ".jpeg", ".webp", ".gif"}:
            with Image.open(path) as im:
                info["w"], info["h"] = im.size
                info["mode"] = im.mode
                info["format"] = im.format
                has_alpha = im.mode in ("RGBA", "LA") or (
                    im.mode == "P" and "transparency" in im.info
                )
                info["alpha"] = has_alpha
                rgba = im.convert("RGBA")
                info["pxhash"] = hashlib.sha256(rgba.tobytes()).hexdigest()[:16]
                info["filehash"] = hashlib.sha256(path.read_bytes()).hexdigest()[:16]
                # rough non-opaque pixel count sample for alpha usefulness
                if has_alpha:
                    extrema = rgba.getextrema()
                    # extrema[3] is (min_a, max_a)
                    info["alpha_min"] = extrema[3][0]
                    info["alpha_max"] = extrema[3][1]
        rows.append(info)

    print("=== ALL ASSETS (largest first) ===")
    print("path\tbytes\tMB\twxh\tmode\talpha\tpxhash")
    for r in sorted(rows, key=lambda x: -x["bytes"]):
        if "w" in r:
            print(
                f"{r['path']}\t{r['bytes']}\t{r['bytes']/1e6:.2f}\t"
                f"{r['w']}x{r['h']}\t{r['mode']}\t{r['alpha']}\t{r['pxhash']}"
            )
        else:
            print(f"{r['path']}\t{r['bytes']}\t{r['bytes']/1e6:.2f}\t-\t-\t-\t-")

    total = sum(r["bytes"] for r in rows)
    png = sum(r["bytes"] for r in rows if r["ext"] == ".png")
    ttf = sum(r["bytes"] for r in rows if r["ext"] == ".ttf")
    txt = sum(r["bytes"] for r in rows if r["ext"] == ".txt")
    jpg = sum(r["bytes"] for r in rows if r["ext"] in {".jpg", ".jpeg"})
    webp = sum(r["bytes"] for r in rows if r["ext"] == ".webp")
    svg = sum(r["bytes"] for r in rows if r["ext"] == ".svg")
    other = total - png - ttf - txt - jpg - webp - svg

    print("\n=== TOTALS ===")
    print(f"TOTAL_BYTES\t{total}\t{total/1e6:.2f} MB")
    print(f"PNG\t{png}\t{png/1e6:.2f} MB")
    print(f"JPG\t{jpg}\t{jpg/1e6:.2f} MB")
    print(f"WEBP\t{webp}\t{webp/1e6:.2f} MB")
    print(f"SVG\t{svg}\t{svg/1e6:.2f} MB")
    print(f"TTF\t{ttf}\t{ttf/1e6:.2f} MB")
    print(f"TXT\t{txt}\t{txt/1e6:.2f} MB")
    print(f"OTHER\t{other}\t{other/1e6:.2f} MB")

    px = defaultdict(list)
    fh = defaultdict(list)
    for r in rows:
        if "pxhash" in r:
            px[r["pxhash"]].append(r["path"])
            fh[r["filehash"]].append(r["path"])

    print("\n=== PIXEL-IDENTICAL GROUPS ===")
    for h, paths in px.items():
        if len(paths) > 1:
            print(h, paths)

    print("\n=== BYTE-IDENTICAL GROUPS ===")
    for h, paths in fh.items():
        if len(paths) > 1:
            print(h, paths)


if __name__ == "__main__":
    main()
