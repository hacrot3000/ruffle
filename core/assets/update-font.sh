#!/bin/bash

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================
# CJK_SIZE_SCALE: Scale factor to increase CJK character size
#   - Default: 1.05 (5% larger than base size)
#   - Set to 1.0 for no additional scaling (just match unitsPerEm)
#   - Increase to make CJK characters larger (e.g., 1.5 = 50% larger, 2.0 = 100% larger)
#   - Recommended range: 1.0 - 2.0
#   - Usage: CJK_SIZE_SCALE=1.5 ./update-font.sh
CJK_SIZE_SCALE=${CJK_SIZE_SCALE:-1.05}

# CJK_FONT_WEIGHT: Font weight for CJK variable fonts
#   - 400 = Regular (default)
#   - 500 = Medium
#   - 600 = SemiBold
#   - 700 = Bold
#   - Usage: CJK_FONT_WEIGHT=700 ./update-font.sh
CJK_FONT_WEIGHT=${CJK_FONT_WEIGHT:-400}

echo "Configuration:"
echo "  CJK_SIZE_SCALE = $CJK_SIZE_SCALE (CJK characters will be ${CJK_SIZE_SCALE}x larger)"
echo "  CJK_FONT_WEIGHT = $CJK_FONT_WEIGHT (400=Regular, 500=Medium, 600=SemiBold, 700=Bold)"
echo ""

echo "1. Copying local fonts"
cp fonts/arial.ttf ./Arial.ttf
cp fonts/tahoma.ttf ./Tahoma.ttf
cp fonts/TimesNewRoman.ttf ./TimesNewRoman.ttf
# cp fonts/NotoSansCJKtc-VF.ttf ./NotoSansCJKtc-VF.ttf
# cp fonts/NotoSansCJKsc-VF.ttf ./NotoSansCJKsc-VF.ttf
# cp fonts/NotoSansSC-VariableFont_wght.ttf ./NotoSansCJKtc-VF.ttf	# Scale 1.05-1.1 is enough
cp fonts/SimSun.ttf ./NotoSansCJKtc-VF.ttf	# Scale 4.0 is enough

echo "1.1. Instantiating CJK variable font to weight $CJK_FONT_WEIGHT"
# Instantiate variable font to specific weight using fonttools
# Export variable for Python script
export CJK_FONT_WEIGHT

python3 << 'PYTHON_INSTANTIATE'
from fontTools import ttLib
from fontTools.varLib import instancer
import os

weight = int(os.environ.get('CJK_FONT_WEIGHT', '400'))
print(f"Instantiating variable font to weight {weight}...")

# Load variable font
font = ttLib.TTFont("NotoSansCJKtc-VF.ttf")

# Check if it's a variable font
if 'fvar' in font:
    # Instantiate to specific weight
    instancer.instantiateVariableFont(font, {"wght": weight})
    print(f"✓ Instantiated to weight {weight}")

    # Remove variable font tables after instantiation
    # Include gvar which causes issues with pyftsubset
    var_tables = ['fvar', 'avar', 'cvar', 'gvar', 'HVAR', 'VVAR', 'MVAR', 'STAT']
    removed = []
    for table in var_tables:
        if table in font:
            del font[table]
            removed.append(table)
    if removed:
        print(f"✓ Removed variable font tables: {', '.join(removed)}")
else:
    print("Note: Not a variable font, skipping instantiation")

# Save instantiated font
font.save("NotoSansCJKtc.ttf")
print("✓ Saved instantiated font as static font")
PYTHON_INSTANTIATE

echo "2. Subsetting Arial.ttf"
pyftsubset --unicodes-file=unicodes-file.txt Arial.ttf --output-file=Arial.subset.ttf

echo "3. Subsetting Tahoma.ttf"
pyftsubset --unicodes-file=unicodes-file.txt Tahoma.ttf --output-file=Tahoma.subset.ttf

echo "4. Subsetting TimesNewRoman.ttf"
pyftsubset --unicodes-file=unicodes-file.txt TimesNewRoman.ttf --output-file=TimesNewRoman.subset.ttf

echo "5. Subsetting NotoSansCJKtc.ttf (Instantiated CJK font)"
# Font already instantiated to specified weight in step 1.1
pyftsubset --unicodes-file=cjk-unicodes.txt NotoSansCJKtc.ttf --output-file=NotoSansCJKtc.subset.ttf --layout-features="*"

# echo "6. Subsetting NotoSansCJKsc-VF.ttf (Simplified Chinese)"
# pyftsubset --unicodes-file=cjk-unicodes.txt NotoSansCJKsc-VF.ttf --output-file=NotoSansCJKsc.subset.ttf --layout-features="*" --no-layout-closure

echo "7. Merging Latin fonts"
pyftmerge Arial.subset.ttf Tahoma.subset.ttf TimesNewRoman.subset.ttf
mv merged.ttf merged-latin.ttf

echo "8. Merging CJK fonts"
# pyftmerge NotoSansCJKtc.subset.ttf NotoSansCJKsc.subset.ttf
pyftmerge NotoSansCJKtc.subset.ttf --output-file=merged.ttf
mv merged.ttf merged-cjk.ttf

echo "9. Scaling CJK font to match Latin font unitsPerEm (1000 -> 2048) and apply size scaling"
# Scale CJK font from 1000 to 2048 unitsPerEm to match Latin fonts
# Additionally apply CJK_SIZE_SCALE to make CJK characters larger
# IMPORTANT: Scale glyph coordinates directly, not just metrics

# Export CJK_SIZE_SCALE for Python script
export CJK_SIZE_SCALE

python3 << 'PYTHON_SCRIPT'
from fontTools import ttLib
import os

# Base scale to match unitsPerEm (1000 -> 2048)
base_scale = 2048.0 / 1000.0
# Additional scale from config
cjk_size_scale = float(os.environ.get('CJK_SIZE_SCALE', '2.0'))
# Combined scale factor
scale_factor = base_scale * cjk_size_scale

print(f"Applying scale factor: {base_scale:.3f} (unitsPerEm) × {cjk_size_scale:.2f} (size) = {scale_factor:.3f} (total)")
print("Scaling glyph coordinates (not just metrics)...")

font = ttLib.TTFont("merged-cjk.ttf")

# Scale head table
head = font['head']
head.unitsPerEm = 2048

# Scale hhea table
hhea = font['hhea']
hhea.ascent = int(hhea.ascent * scale_factor)
hhea.descent = int(hhea.descent * scale_factor)
hhea.lineGap = int(hhea.lineGap * scale_factor)
hhea.advanceWidthMax = int(hhea.advanceWidthMax * scale_factor)
hhea.minLeftSideBearing = int(hhea.minLeftSideBearing * scale_factor)
hhea.minRightSideBearing = int(hhea.minRightSideBearing * scale_factor)
hhea.xMaxExtent = int(hhea.xMaxExtent * scale_factor)

# Scale OS/2 table
if 'OS/2' in font:
    os2 = font['OS/2']
    os2.sTypoAscender = int(os2.sTypoAscender * scale_factor)
    os2.sTypoDescender = int(os2.sTypoDescender * scale_factor)
    os2.sTypoLineGap = int(os2.sTypoLineGap * scale_factor)
    os2.usWinAscent = int(os2.usWinAscent * scale_factor)
    os2.usWinDescent = int(os2.usWinDescent * scale_factor)
    if hasattr(os2, 'sxHeight'):
        os2.sxHeight = int(os2.sxHeight * scale_factor)
    if hasattr(os2, 'sCapHeight'):
        os2.sCapHeight = int(os2.sCapHeight * scale_factor)

# Scale hmtx table (advanceWidth and lsb)
hmtx = font['hmtx']
for glyph_name in hmtx.metrics:
    advance_width, lsb = hmtx.metrics[glyph_name]
    hmtx.metrics[glyph_name] = (int(advance_width * scale_factor), int(lsb * scale_factor))

# Scale glyf table - THIS IS THE KEY: scale all coordinates, not just bbox
if 'glyf' in font:
    glyf = font['glyf']
    glyph_count = 0
    for glyph_name in glyf.keys():
        glyph = glyf[glyph_name]

        if glyph.isComposite():
            # For composite glyphs, scale the component positions and transforms
            for component in glyph.components:
                # Scale component position
                if hasattr(component, 'x') and component.x is not None:
                    component.x = int(component.x * scale_factor)
                if hasattr(component, 'y') and component.y is not None:
                    component.y = int(component.y * scale_factor)
                # Scale transform matrix if present (for scaling components)
                if hasattr(component, 'transform'):
                    transform = component.transform
                    if hasattr(transform, 'xx') and transform.xx is not None:
                        # Transform matrix: scale the scale factors
                        # Note: We don't scale translation (dx, dy) here as they're already scaled above
                        pass  # Keep transform as is, position already scaled
            # Scale bbox for composite glyphs (check if attributes exist)
            if hasattr(glyph, 'xMin') and glyph.xMin is not None:
                glyph.xMin = int(glyph.xMin * scale_factor)
            if hasattr(glyph, 'xMax') and glyph.xMax is not None:
                glyph.xMax = int(glyph.xMax * scale_factor)
            if hasattr(glyph, 'yMin') and glyph.yMin is not None:
                glyph.yMin = int(glyph.yMin * scale_factor)
            if hasattr(glyph, 'yMax') and glyph.yMax is not None:
                glyph.yMax = int(glyph.yMax * scale_factor)
        else:
            # For simple glyphs, scale all coordinates
            if hasattr(glyph, 'coordinates') and glyph.coordinates:
                # GlyphCoordinates is a special object, scale each coordinate
                from fontTools.ttLib.tables._g_l_y_f import GlyphCoordinates
                coords = glyph.coordinates
                # Scale each coordinate point
                scaled_coords = []
                for i in range(len(coords)):
                    x, y = coords[i]
                    scaled_coords.append((int(x * scale_factor), int(y * scale_factor)))
                glyph.coordinates = GlyphCoordinates(scaled_coords)

                # Recalculate bbox from scaled coordinates
                xs = [c[0] for c in scaled_coords]
                ys = [c[1] for c in scaled_coords]
                if xs and ys:
                    glyph.xMin = min(xs)
                    glyph.xMax = max(xs)
                    glyph.yMin = min(ys)
                    glyph.yMax = max(ys)
            else:
                # Fallback: scale bbox directly (shouldn't happen normally)
                # Also handles empty glyphs - check if attributes exist
                if hasattr(glyph, 'xMin') and glyph.xMin is not None:
                    glyph.xMin = int(glyph.xMin * scale_factor)
                if hasattr(glyph, 'xMax') and glyph.xMax is not None:
                    glyph.xMax = int(glyph.xMax * scale_factor)
                if hasattr(glyph, 'yMin') and glyph.yMin is not None:
                    glyph.yMin = int(glyph.yMin * scale_factor)
                if hasattr(glyph, 'yMax') and glyph.yMax is not None:
                    glyph.yMax = int(glyph.yMax * scale_factor)

        glyph_count += 1
        if glyph_count % 1000 == 0:
            print(f"  Scaled {glyph_count} glyphs...")

print(f"  Scaled {glyph_count} glyphs total")

# Remove variable font tables
for table in ['vhea', 'vmtx', 'fvar', 'avar', 'HVAR', 'VVAR', 'MVAR']:
    if table in font:
        del font[table]

font.save("merged-cjk-scaled.ttf")
print(f"Scaled CJK font: unitsPerEm 1000->2048, size scale {cjk_size_scale:.2f}x")
print("✓ Glyph coordinates scaled (characters will actually grow larger)")
PYTHON_SCRIPT

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
