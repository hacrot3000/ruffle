# Font Configuration Guide

Script `update-font.sh` hỗ trợ điều chỉnh kích thước và độ đậm của chữ tiếng Trung.

## 1. CJK Size Scaling

Điều chỉnh kích thước chữ tiếng Trung thông qua biến `CJK_SIZE_SCALE`.

### Cách sử dụng:

1. **Sử dụng giá trị mặc định (1.05 = 5% lớn hơn):**
   ```bash
   ./update-font.sh
   ```

2. **Tùy chỉnh kích thước:**
   ```bash
   # Tăng 50% kích thước
   CJK_SIZE_SCALE=1.5 ./update-font.sh

   # Tăng 100% kích thước (gấp đôi)
   CJK_SIZE_SCALE=2.0 ./update-font.sh

   # Không tăng thêm (chỉ match unitsPerEm)
   CJK_SIZE_SCALE=1.0 ./update-font.sh
   ```

### Giá trị khuyến nghị:

- `1.0` - Kích thước gốc (không tăng thêm)
- `1.05` - Mặc định, tăng 5% (khuyến nghị cho NotoSans)
- `1.5` - Tăng 50% (khuyến nghị cho SimSun nếu dùng)
- `2.0` - Tăng 100% (gấp đôi)

## 2. CJK Font Weight

Điều chỉnh độ đậm của chữ tiếng Trung thông qua biến `CJK_FONT_WEIGHT`.

### Cách sử dụng:

1. **Sử dụng giá trị mặc định (400 = Regular):**
   ```bash
   ./update-font.sh
   ```

2. **Chọn độ đậm khác:**
   ```bash
   # Bold
   CJK_FONT_WEIGHT=700 ./update-font.sh

   # Medium
   CJK_FONT_WEIGHT=500 ./update-font.sh

   # SemiBold
   CJK_FONT_WEIGHT=600 ./update-font.sh
   ```

### Giá trị có sẵn:

- `400` - Regular (mặc định, không đậm)
- `500` - Medium (hơi đậm)
- `600` - SemiBold (đậm vừa)
- `700` - Bold (đậm)

**Lưu ý:** Chỉ áp dụng cho variable fonts (NotoSansSC). Nếu dùng static fonts (SimSun) sẽ bị bỏ qua.

## 3. Kết hợp cả hai

Bạn có thể kết hợp cả size và weight:

```bash
# Chữ to và đậm
CJK_SIZE_SCALE=1.5 CJK_FONT_WEIGHT=700 ./update-font.sh

# Chữ đậm kích thước bình thường
CJK_FONT_WEIGHT=700 ./update-font.sh

# Xuất biến để dùng nhiều lần
export CJK_SIZE_SCALE=1.2
export CJK_FONT_WEIGHT=600
./update-font.sh
```

## Lưu ý chung:

- Giá trị quá lớn (CJK_SIZE_SCALE > 2.0) có thể làm chữ bị méo hoặc quá lớn
- Nên test với các giá trị khác nhau để tìm giá trị phù hợp nhất
- Variable fonts cho phép chọn weight linh hoạt, static fonts không
