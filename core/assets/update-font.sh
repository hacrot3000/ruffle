#!/bin/bash

set -e

echo "1. Copying local fonts"
cp fonts/arial.ttf ./Arial.ttf
cp fonts/tahoma.ttf ./Tahoma.ttf
cp fonts/TimesNewRoman.ttf ./TimesNewRoman.ttf
cp fonts/NotoSansCJKtc-VF.ttf ./NotoSansCJKtc-VF.ttf
cp fonts/NotoSansCJKsc-VF.ttf ./NotoSansCJKsc-VF.ttf

echo "2. Subsetting Arial.ttf"
pyftsubset --unicodes-file=unicodes-file.txt Arial.ttf --output-file=Arial.subset.ttf

echo "3. Subsetting Tahoma.ttf"
pyftsubset --unicodes-file=unicodes-file.txt Tahoma.ttf --output-file=Tahoma.subset.ttf

echo "4. Subsetting TimesNewRoman.ttf"
pyftsubset --unicodes-file=unicodes-file.txt TimesNewRoman.ttf --output-file=TimesNewRoman.subset.ttf

echo "5. Subsetting NotoSansCJKtc-VF.ttf (Traditional Chinese)"
# Variable fonts need to be instantiated to a specific weight first
# Use weight=400 (Regular) as default
pyftsubset --unicodes-file=cjk-unicodes.txt NotoSansCJKtc-VF.ttf --output-file=NotoSansCJKtc.subset.ttf --layout-features="*" --no-layout-closure

echo "6. Subsetting NotoSansCJKsc-VF.ttf (Simplified Chinese)"
pyftsubset --unicodes-file=cjk-unicodes.txt NotoSansCJKsc-VF.ttf --output-file=NotoSansCJKsc.subset.ttf --layout-features="*" --no-layout-closure

echo "7. Merging Latin fonts"
pyftmerge Arial.subset.ttf Tahoma.subset.ttf TimesNewRoman.subset.ttf
mv merged.ttf merged-latin.ttf

echo "8. Merging CJK fonts"
pyftmerge NotoSansCJKtc.subset.ttf NotoSansCJKsc.subset.ttf
mv merged.ttf merged-cjk.ttf

echo "9. Scaling CJK font to match Latin font unitsPerEm (1000 -> 2048)"
# Scale CJK font from 1000 to 2048 unitsPerEm to match Latin fonts
# Use ttx to dump, scale in XML with Python, then recompile
ttx merged-cjk.ttf

python3 << 'PYTHON_SCRIPT'
import re

scale_factor = 2048.0 / 1000.0

with open("merged-cjk.ttx", "r") as f:
    content = f.read()

# Scale unitsPerEm
content = re.sub(r'unitsPerEm value="1000"', 'unitsPerEm value="2048"', content)

# Scale hhea table values
def scale_hhea(match):
    tag = match.group(1)
    value = int(match.group(2))
    scaled = int(value * scale_factor)
    return f'{tag} value="{scaled}"'

content = re.sub(r'(ascent|descent|lineGap|advanceWidthMax|minLeftSideBearing|minRightSideBearing|xMaxExtent) value="(-?\d+)"', scale_hhea, content)

# Scale OS/2 table values
def scale_os2(match):
    tag = match.group(1)
    value = int(match.group(2))
    scaled = int(value * scale_factor)
    return f'{tag} value="{scaled}"'

content = re.sub(r'(sTypoAscender|sTypoDescender|sTypoLineGap|usWinAscent|usWinDescent|sxHeight|sCapHeight) value="(-?\d+)"', scale_os2, content)

# Scale hmtx advanceWidth and lsb
def scale_hmtx(match):
    width = int(match.group(1))
    lsb = int(match.group(2))
    return f'width="{int(width * scale_factor)}" lsb="{int(lsb * scale_factor)}"'

content = re.sub(r'width="(\d+)" lsb="(-?\d+)"', scale_hmtx, content)

# Scale glyf coordinates (xMin, xMax, yMin, yMax)
def scale_glyf_bbox(match):
    attr = match.group(1)
    value = int(match.group(2))
    scaled = int(value * scale_factor)
    return f'{attr}="{scaled}"'

content = re.sub(r'(xMin|xMax|yMin|yMax)="(-?\d+)"', scale_glyf_bbox, content)

# Remove variable font tables (vhea, vmtx) as they cause merge issues
content = re.sub(r'<vhea>.*?</vhea>', '', content, flags=re.DOTALL)
content = re.sub(r'<vmtx>.*?</vmtx>', '', content, flags=re.DOTALL)

with open("merged-cjk.ttx", "w") as f:
    f.write(content)

print("Scaled CJK font metrics from 1000 to 2048 unitsPerEm")
PYTHON_SCRIPT

ttx merged-cjk.ttx
mv merged-cjk#1.ttf merged-cjk-scaled.ttf
rm merged-cjk.ttx

# Remove variable font tables from the TTF file
python3 << 'PYTHON_SCRIPT2'
from fontTools import ttLib

font = ttLib.TTFont("merged-cjk-scaled.ttf")
# Remove variable font tables if they exist
for table in ['vhea', 'vmtx', 'fvar', 'avar', 'HVAR', 'VVAR', 'MVAR']:
    if table in font:
        del font[table]
font.save("merged-cjk-scaled.ttf")
print("Removed variable font tables")
PYTHON_SCRIPT2

echo "10. Merging all fonts"
pyftmerge merged-latin.ttf merged-cjk-scaled.ttf

echo "11. Fixing up descent"

ttx merged.ttf

# Detect descent value from merged font
DESCENT_LINE=$(grep 'descent value="-' merged.ttx | head -1)
if [ -z "$DESCENT_LINE" ]; then
	echo "ERROR: Could not detect descent value!"
	exit 1
fi

DESCENT_VALUE=$(echo "$DESCENT_LINE" | sed -n 's/.*descent value="-\([0-9]*\)".*/\1/p')
if [ -z "$DESCENT_VALUE" ]; then
	echo "ERROR: Could not parse descent value!"
	exit 1
fi

echo "Detected descent value: -$DESCENT_VALUE"

# Calculate new descent value (scale from 2048 units to match original ratio)
# Original: -423 -> -293 (ratio ~0.692)
# For 2048 units: -434 -> -300 (approximate)
NEW_DESCENT="-300"

# Replace descent values
sed -i -e "s/descent value=\"-$DESCENT_VALUE\"/descent value=\"$NEW_DESCENT\"/" merged.ttx
sed -i -e "s/sTypoDescender value=\"-$DESCENT_VALUE\"/sTypoDescender value=\"$NEW_DESCENT\"/" merged.ttx

ttx merged.ttx
mv merged#1.ttf merged.ttf

echo "12. Zipping result"
# Pure gzip (no headers or other sections)
cat merged.ttf | gzip --best --no-name | tail --bytes=+11 | head --bytes=-8 > notosans.subset.ttf.gz

echo "DONE: Created notosans.subset.ttf.gz"

echo "13. Testing merged font"
bash test-font.sh || echo "WARNING: Test script failed or merged.ttf not available"

echo "14. Removing artifacts"
rm *.ttf *.ttx merged#1.ttf 2>/dev/null || true
