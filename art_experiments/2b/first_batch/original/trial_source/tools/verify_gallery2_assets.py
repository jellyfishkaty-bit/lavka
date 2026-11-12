#!/usr/bin/env python3
"""Offline preflight for owner-approved Gallery #2 PNGs. No network activity."""
import hashlib
import json
import struct
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
data = json.loads((root / "gallery2_manifest.json").read_text(encoding="utf-8"))
failures = []
for item in data["assets"]:
    file = root / item["asset"]
    name = item["id"]
    if not file.is_file():
        failures.append(f"{name}: missing {item['asset']}")
        continue
    raw = file.read_bytes()
    if len(raw) < 29 or raw[:8] != b"\x89PNG\r\n\x1a\n":
        failures.append(f"{name}: invalid PNG signature")
        continue
    w, h, depth, color, *_ = struct.unpack(">IIBBBBB", raw[16:29])
    digest = hashlib.sha256(raw).hexdigest()
    if (w, h) != (item["png_width"], item["png_height"]):
        failures.append(f"{name}: wrong dimensions {w}x{h}")
    if color != 6:
        failures.append(f"{name}: expected RGBA PNG color type 6, got {color}")
    if digest != item["sha256"]:
        failures.append(f"{name}: SHA-256 differs from approved preview")
    print(f"{name:8} {w}x{h} sha256={digest[:16]}...")

print(f"Gallery #2 preflight: {len(data['assets'])-len(failures)}/{len(data['assets'])} accepted")
for failure in failures:
    print("FAIL:", failure, file=sys.stderr)
if failures:
    raise SystemExit(1)
