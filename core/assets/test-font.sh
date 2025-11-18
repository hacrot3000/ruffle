#!/bin/bash

# Test script to check font coverage similar to the requested output

set -e

echo "Testing merged font..."

if [ ! -f "merged.ttf" ]; then
    echo "ERROR: merged.ttf not found. Please run update-font.sh first."
    exit 1
fi

python3 << 'EOF'
from fontTools import ttLib

font = ttLib.TTFont("merged.ttf")
cmap = font.getBestCmap()

print("Checking merged font...")
print()
print(f"Total glyphs: {len(cmap)}")

# Check Vietnamese characters
viet_chars = [0x103, 0xe2, 0x111, 0xea, 0xf4, 0x1a1, 0x1b0, 0x1ea0, 0x1ea2]
found_viet = sum(1 for c in viet_chars if c in cmap)
print(f"Vietnamese characters: {found_viet}/{len(viet_chars)}")

# Check CJK sample characters
cjk_samples = [0x4E00, 0x4E01, 0x4E02, 0x4E03, 0x4E04]
found_cjk = sum(1 for c in cjk_samples if c in cmap)
print(f"CJK sample characters: {found_cjk}/{len(cjk_samples)}")

# Check CJK ranges
print()
print("CJK ranges coverage:")
ranges = [
    (0x4E00, 0x9FFF, "CJK Unified Ideographs (basic)"),
    (0x3400, 0x4DBF, "CJK Unified Ideographs Extension A"),
    (0x20000, 0x2A6DF, "CJK Unified Ideographs Extension B"),
]
for start, end, name in ranges:
    # Sample first 100 characters in range
    sample_size = min(100, end - start + 1)
    count = sum(1 for c in range(start, start + sample_size) if c in cmap)
    total_in_range = sum(1 for c in range(start, end + 1) if c in cmap)
    print(f"  {name}: {total_in_range} chars found (sampled {count}/{sample_size})")
EOF
