# Hướng dẫn sử dụng Ruffle sau khi build

## Build đã hoàn thành thành công! ✅

Thư mục build: `/home/duongtc/568E/Haitac/ruffle/dist`

### Các file quan trọng
- `ruffle_web.js` - WASM JavaScript bindings
- `ruffle_web_bg.wasm` - WebAssembly module  
- `ruffle-imports.js` - JavaScript imports cho WASM
- `index.js` - Entry point chính
- `load-ruffle.js` - Ruffle loader
- Other support files

## Cách sử dụng trong trang web

### Cách 1: Sử dụng qua index.js (Khuyến nghị)

```html
<!DOCTYPE html>
<html>
<head>
    <title>Ruffle Demo</title>
</head>
<body>
    <div id="container"></div>
    
    <script type="module">
        // Import Ruffle API
        import {Setup, Player} from "/ruffle/dist/index.js";
        
        // Cài đặt Ruffle plugin
        Setup.installPlugin();index2
        
        // Tạo player element
        const player = Player.RufflePlayer.newest().createPlayer();
        const container = document.getElementById("container");
        container.appendChild(player);
        
        // Load file SWF
        player.load("path/to/your.swf");
    </script>
</body>
</html>
```

### Cách 2: Sử dụng RuffleInstanceBuilder trực tiếp

```html
<script type="module">
    import { createRuffleBuilder } from "/ruffle/dist/load-ruffle.js";
    
    async function initRuffle() {
        const [builder, zipWriterAsync] = await createRuffleBuilder();
        
        const container = document.getElementById("container");
        const [instance, promise] = await builder.build(container, null);
        
        // Load SWF data
        const swfData = await fetch("path/to/your.swf").then(r => r.arrayBuffer());
        instance.load_data(new Uint8Array(swfData), {}, "game.swf");
    }
    
    initRuffle();
</script>
```

### Cách 3: Nhúng tự động bằng custom element (Dễ nhất)

```html
<script src="/ruffle/dist/polyfills.js"></script>
<script type="module">
    import {Setup} from "/ruffle/dist/index.js";
    Setup.installPlugin();
</script>

<!-- Ruffle sẽ tự động thay thế thẻ embed/object -->
<embed src="path/to/your.swf" width="800" height="600" />
```

## Lưu ý quan trọng

1. **File ruffle-imports.js** đã được tạo bởi npm build và chứa các hàm JavaScript được gọi từ WASM
2. **Phải deploy cả thư mục dist** lên web server
3. **Sử dụng HTTPS hoặc localhost** vì WASM yêu cầu secure context
4. **CORS headers** cần được cấu hình đúng nếu file SWF ở domain khác

## Deploy lên server

Copy toàn bộ thư mục dist:
```bash
cp -r /home/duongtc/568E/Haitac/ruffle/dist/* /đường/dẫn/webroot/ruffle/dist/
```

## Kiểm tra trong trình duyệt

Mở console và kiểm tra:
```javascript
// Không nên có lỗi "failed to grow table" nữa
// Không nên có lỗi "Cannot find module './ruffle-imports'" nữa
```

## Các sửa đổi đã thực hiện

1. **core/Cargo.toml**: Thêm getrandom với wasm_js feature
2. **build_web.sh**: 
   - Thêm `--cfg web_sys_unstable_apis` để hỗ trợ WebCodecs
   - Thêm `--weak-refs --reference-types` cho wasm-bindgen
   - Thêm npm build step tạo JavaScript wrappers

## Troubleshooting

Nếu vẫn gặp lỗi:
- Kiểm tra console browser để xem lỗi cụ thể
- Đảm bảo tất cả file trong dist đã được deploy
- Kiểm tra MIME types: `.wasm` phải là `application/wasm`
- Kiểm tra đường dẫn import trong code HTML
