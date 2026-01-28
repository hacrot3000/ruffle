<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "//www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="//www.w3.org/1999/xhtml" lang="en" xml:lang="en">

<head>
    <title>Vua Hải Tặc</title>
    <meta name="google" value="notranslate" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans&family=Noto+Serif&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans&family=Noto+Serif&display=swap">



    <style type="text/css" media="screen">
        html,
        body {
            height: 100%;
        }

        body {
            margin: 0;
            padding: 0;
            overflow: auto;
            text-align: center;
            background-color: #747474;
        }

        object:focus {
            outline: none;
        }

        #flashContent {
            display: none;
        }

        body {
            font-family: Arial, sans-serif;
            padding: 20px;
        }

        .lang-select {
            margin-bottom: 20px;
        }

        button,
        .lang-select a {
            /* margin-right: 10px;
            padding: 6px 12px;
            font-size: 14px;
            cursor: pointer;
            display: inline-block;
            text-decoration: none;
            border: 1px solid #ccc;
            background-color: #f0f0f0;
            color: #333;
            border-radius: 4px; */
            display: inline-flex;
            /* dùng flex để căn giữa */
            align-items: center;
            /* căn giữa theo chiều dọc */
            justify-content: center;
            /* căn giữa theo chiều ngang */
            width: 130px;
            /* cố định chiều rộng */
            height: 36px;
            /* cố định chiều cao */
            margin-right: 10px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            color: white;
            background-color: #007bff;
            border: 1px solid #007bff;
            border-radius: 4px;
            transition: background-color 0.2s, border-color 0.2s;
            box-sizing: border-box;
        }

        .lang-select a:hover {
            /* background-color: #e0e0e0; */
            background-color: #0056b3;
            /* màu nền khi hover */
            border-color: #0056b3;
            text-decoration: none;
        }

        .flash-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(520px, 1fr));
            gap: 20px;
        }

        .flash-section {
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 10px;
            box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.1);
            background-color: #fafafa;
        }

        .flash-title {
            font-weight: bold;
            margin-bottom: 8px;
            text-align: center;
        }
    </style>

    <script>
        // Hàm test kết nối WSS
        function testWebSocketConnection(url) {
            console.log(`Đang thử kết nối đến: ${url}`);

            try {
                const socket = new WebSocket(url);

                socket.onopen = function (e) {
                    console.log(`✅ Kết nối thành công: ${url}`);
                    // Gửi một tin nhắn test
                    socket.send("Test message");
                };

                socket.onmessage = function (event) {
                    console.log(`📥 Nhận dữ liệu từ ${url}:`, event.data);
                };

                socket.onclose = function (event) {
                    if (event.wasClean) {
                        console.log(`🔒 Kết nối đóng sạch: ${url}, mã=${event.code}, lý do=${event.reason}`);
                    } else {
                        // Ví dụ: server process killed hoặc network down
                        console.error(`❌ Kết nối bị ngắt: ${url}, mã=${event.code}`);
                    }
                };

                socket.onerror = function (error) {
                    console.error(`❌ Lỗi kết nối ${url}:`, error);
                };

                // Trả về socket để có thể đóng sau
                return socket;
            } catch (error) {
                console.error(`❌ Không thể tạo kết nối ${url}:`, error);
                return null;
            }
        }

        // Danh sách các URL để test
        const wsUrls = [
            //			'ws://ss14-local.568int.com:18001',
            //			'wss://ss14-local.568int.com:18002',
            //			'wss://ss14-local.568int.com:28001',
            //			'wss://ss14-local.568int.com:28002',
            //			'wss://ss14-local.568int.com:9080'
        ];

        // Test tất cả các kết nối
        const connections = wsUrls.map(url => testWebSocketConnection(url));

        // Đóng tất cả kết nối sau 10 giây
        setTimeout(() => {
            console.log('Đóng tất cả kết nối sau 10 giây...');
            connections.forEach(socket => {
                if (socket && socket.readyState === WebSocket.OPEN) {
                    socket.close();
                }
            });
        }, 10000);

        // Hiển thị trạng thái kết nối sau 5 giây
        setTimeout(() => {
            console.log('--- Trạng thái kết nối sau 5 giây ---');
            connections.forEach((socket, index) => {
                if (!socket) {
                    console.log(`${wsUrls[index]}: Không thể khởi tạo kết nối`);
                    return;
                }

                const states = {
                    0: 'CONNECTING',
                    1: 'OPEN',
                    2: 'CLOSING',
                    3: 'CLOSED'
                };

                console.log(`${wsUrls[index]}: ${states[socket.readyState]}`);
            });
        }, 5000);


        window.RufflePlayer = window.RufflePlayer || {};
        window.RufflePlayer.config = {
            axExecutionDuration: 0, // không giới hạn thời gian
            "autoplay": "on",
            "unmuteOverlay": "hidden",
            "splashScreen": false,
            "logLevel": "info",
            "socketProxy": [{
                "host": "10.9.4.10",
                "port": 8002,
                "proxyUrl": "wss://ss14-local.568int.com:28002"
            },
            {
                "host": "10.9.4.10",
                "port": 8001,
                "proxyUrl": "wss://ss14-local.568int.com:28001"
            },
            ]
        };
        /*

    ./websocat --binary log:ws-l:0.0.0.0:9080 log:tcp:127.0.0.1:8001

./websocat --binary \
  log:wss-l:0.0.0.0:9080 \
  log:tcp:10.9.4.10:8001 \
  --pkcs12-der /home/pirate/static/ssl-websocket/output.pkcs12

./websocat --binary \
  log:wss-l:0.0.0.0:9080 \
  log:tcp:10.9.4.10:8001 \
  --pkcs12-der /home/pirate/static/ssl-websocket/output.p12

openssl pkcs12 -export \
  -inkey /home/pirate/certsclient/ssl/568int.com.pem \
  -in /home/pirate/certsclient/ssl/568int.com.pem \
  -out output.p12 \
  -certpbe AES-256-CBC \
  -keypbe AES-256-CBC


    */
    </script>
    <!-- <script src="https://unpkg.com/@ruffle-rs/ruffle"></script>				-->
    <!--<script src="/ruffle/dist/ruffle_web.js?v=<?php echo time() ?>"></script> -->
    <script type="module">
        import { Setup, Player } from "/ruffle/dist/index.js?v=<?php echo time() ?>";

        init().then(() => {
            console.log("Ruffle wasm loaded");
        });
    </script>

    <script type="text/javascript" src="//ss14-local.568int.com//swfobject.js"></script>
    <script type="text/javascript">
        var bid = getQuery('bid');
        if (bid) {
            window.location.href = '//ss14-lianyun.568play.vn/api/replay/?serverid=' + getQuery('serverid') + '&bid=' + bid;
        }

        var swfVersionStr = "10.2.0";
        var xiSwfUrlStr = "playerProductInstall.swf";
        var flashvars = {};
        flashvars.host = "10.9.4.10";
        flashvars.assetPath = "//ss14-local.568int.com//assets/";
        flashvars.AMF = 3;
        flashvars.maxChars = 10;
        flashvars.globalization = "<?php echo empty($_GET['lang']) ? 'vi' : $_GET['lang'] ?>";
        flashvars.offset = -420;
        flashvars.swfURL = "//ss14-local.568int.com//Main.swf";
        flashvars.configURL = "//ss14-local.568int.com//loadingTips.xml";
        flashvars.questionUrl = '//ss14-local.568int.com/';
        flashvars.noticeUrl = 'notice.php';
        flashvars.recordUrl = '//ss14-local.568int.com/';
        flashvars.checkCardUrl = '//ss14-local.568int.com/';
        flashvars.bbsUrl = '//ss14-local.568int.com/';
        flashvars.openDateTime = "2024-10-01-10-00-00";
        // flashvars.openDateTime = "2024-10-01-10-00-00";
        flashvars.openPrize = "2012-05-31";
        flashvars.hookMaxNum = 1000;
        flashvars.opclient = 1;
        flashvars.preview = 1;
        flashvars.clientDownLoad = "//haitac.568play.vn/Vua_Hai_Tac.exe";
        flashvars.pay_url = "https://id.568play.vn/payment/momo";

        var serverID = getQuery('sid');
        if (serverID == undefined) {
            serverID = '1';
        }

        flashvars.serverID = "game2000" + serverID;
        flashvars.port = parseInt(8000 + parseInt(serverID));
        flashvars.pid = getQuery('pid');;

        if (flashvars.pid == undefined || flashvars.serverID == undefined) {
            // alert("Ivalid request, give me pid and sid.");
            if (!bid) {
                window.location.href = "/list.php";
            }
        }

        var timestamp = Date.now();

        var params = {};
        params.quality = "high";
        params.bgcolor = "#000000";
        params.allowscriptaccess = "always";
        params.allowfullscreen = "true";

        var attributes = {};
        attributes.id = "loading";
        attributes.name = "loading";
        attributes.align = "middle";

        function getcookie(name) {
            var arr = document.cookie.match(new RegExp("(^| )" + name + "=([^;]*)(;|$)"));
            if (arr != null) {
                return unescape(arr[2]);
            }
            return "fail";
        }

        function setcookie(cookieName, cookieValue, day, path, domain, secure) {
            var expires = new Date();
            expires.setTime(expires.getTime() + day * 24 * 60 * 60 * 1000);
            document.cookie = escape(cookieName) + '=' + escape(cookieValue) +
                (expires ? '; expires=' + expires.toGMTString() : '') +
                (path ? '; path=' + path : '/') +
                (domain ? '; domain=' + domain : '') +
                (secure ? '; secure' : '');
        }

        function thisMovie(movieName) {
            if (navigator.appName.indexOf("Microsoft") != -1) {
                return window[movieName];
            } else {
                return document[movieName];
            }
        }

        function getQuery(variable) {
            var query = window.location.search.substring(1);
            var vars = query.split('&');
            for (var i = 0; i < vars.length; i++) {
                var pair = vars[i].split('=');
                if (decodeURIComponent(pair[0]) == variable) {
                    return decodeURIComponent(pair[1]);
                }
            }
        }

        function addBookmark(title, url) {
            if (document.all) {
                window.external.addFavorite(url, title);
            } else if (window.sidebar) {
                window.sidebar.addPanel(title, url, "");
            } else {
                alert(favorite);
            }
        }

        // Khởi tạo và quản lý Ruffle Player
        let rufflePlayer = null;
        let resetAttempts = 0;
        const MAX_RESET_ATTEMPTS = 5;
        const RESET_COOLDOWN = 2000; // 2 giây

        function initRufflePlayer() {
            try {
                // Đảm bảo container tồn tại
                const container = document.getElementById('ruffle-container');
                if (!container) {
                    console.error("Ruffle container not found");
                    return;
                }

                // Xóa player cũ nếu có
                while (container.firstChild) {
                    container.removeChild(container.firstChild);
                }

                // Khởi tạo player mới
                if (window.RufflePlayer && window.RufflePlayer.newest) {
                    const ruffle = window.RufflePlayer.newest();
                    rufflePlayer = ruffle.createPlayer();
                    container.appendChild(rufflePlayer);

                    // Đặt kích thước
                    const screenWidth = Math.min(document.body.offsetWidth, 1260);
                    const screenHeight = Math.min(document.body.offsetHeight, 660);
                    rufflePlayer.style.width = screenWidth + "px";
                    rufflePlayer.style.height = screenHeight + "px";

                    // Đăng ký sự kiện lỗi
                    rufflePlayer.addEventListener('error', handleRuffleError);
                    rufflePlayer.addEventListener('panic', handleRuffleError);

                    // Load SWF
                    const swfUrl = "//ss14-local.568int.com/loading.swf?v=" + timestamp;
                    rufflePlayer.load({
                        url: swfUrl,
                        parameters: flashvars
                    });

                    resetAttempts = 0; // Reset counter on successful init
                    console.log("Ruffle player initialized successfully");
                } else {
                    alert("Ruffle player không khả dụng. Vui lòng tải lại trang.");
                }
            } catch (error) {
                console.error("Error initializing Ruffle player:", error);
                handleRuffleError(error);
            }
        }

        function handleRuffleError(event) {
            console.error("Ruffle error:", event);

            // Check if it's a rust allocation error or any other error
            const errorMessage = event.message || (event.error && event.error.message) || "Unknown error";
            const isRustError = errorMessage.includes("__rust_alloc_error_handler");

            if (resetAttempts < MAX_RESET_ATTEMPTS) {
                resetAttempts++;
                alert(`Ruffle player gặp lỗi${isRustError ? " bộ nhớ" : ""}: ${errorMessage}\nĐang thử khởi động lại (${resetAttempts}/${MAX_RESET_ATTEMPTS})...`);

                // Delay reset to avoid rapid resets
                setTimeout(initRufflePlayer, RESET_COOLDOWN);
            } else {
                alert(`Ruffle player đã gặp lỗi quá nhiều lần. Vui lòng tải lại trang.`);
            }
        }

        // Resize handler
        function doResize() {
            if (!rufflePlayer) {
                return;
            }

            const screenWidth = Math.min(document.body.offsetWidth, 1260);
            const screenHeight = Math.min(document.body.offsetHeight, 660);

            rufflePlayer.style.width = screenWidth + "px";
            rufflePlayer.style.height = screenHeight + "px";

            resizeTimer = null;
        }

        // Khởi tạo Ruffle sau khi trang đã load
        window.addEventListener('DOMContentLoaded', function () {
            initRufflePlayer();
        });

        // Resize event
        var resizeTimer = null;
        window.onresize = function () {
            if (resizeTimer == null) {
                resizeTimer = setTimeout(doResize, 30);
            }
        }

        // Bắt lỗi toàn cục để reset player
        window.addEventListener("error", e => {
            console.error("JS Error:", e.message);
            if (String(e.message).includes("__rg_oom")) {
                console.warn("Ruffle OOM → khởi động lại player");
                alert("Ruffle OOM → khởi động lại player");
                initRufflePlayer(); // gọi lại hàm thay vì reload trang
            }
            if (String(e.message).includes("unreachable executed")) {
                console.warn("Ruffle unreachable executed → khởi động lại player");
                alert("Ruffle unreachable executed → khởi động lại player");
                //document.location.reload();
            }
        });

        window.addEventListener("unhandledrejection", e => {
            console.error("Unhandled promise rejection:", e.reason);
            if (String(e.reason).includes("__rg_oom")) {
                console.warn("Ruffle OOM → khởi động lại player");
                alert("Ruffle OOM → khởi động lại player");
                initRufflePlayer(); // gọi lại hàm thay vì reload trang
            }
            if (String(e.reason).includes("unreachable executed")) {
                console.warn("Ruffle unreachable executed → khởi động lại player");
                alert("Ruffle unreachable executed → khởi động lại player");
                //document.location.reload();
            }
        });
    </script>
</head>

<body style="overflow-x: hidden;overflow-y: hidden">
    <div class="lang-select">
        <span>Chọn ngôn ngữ:</span>
        <a href="/indextest2.php?sid=<?php echo $_GET['sid'] ?>&pid=<?php echo $_GET['pid'] ?>&lang=vi">Tiếng Việt</a>
        <a href="/indextest2.php?sid=<?php echo $_GET['sid'] ?>&pid=<?php echo $_GET['pid'] ?>&lang=cn">中文 (Tiếng
            Trung)</a>
    </div>

    <div id="ruffle-container"></div>

    <script>
        function get_flashvar() {
            xxw = window.open('');
            xxw.document.write('<code>' + JSON.stringify(flashvars))
        }
    </script>
    <br />
    <center>
        <a href="javascript:get_flashvar();" style="color:white; margin-right: 15px;">flashvars</a>
        <a href="javascript:initRufflePlayer();" style="color:white;">Restart Player</a>
    </center>
</body>

</html>