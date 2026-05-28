<?php
// FORZAR MODO DEPURACIÓN (Útil para el entorno de desarrollo del clúster)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// INYECCIÓN DIRECTA DE REDIS (Sesiones persistentes AWS)
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://54.197.85.133:6379?timeout=3');

// OBLIGATORIO: Configuración de cookies entre servidores del grupo 3
session_set_cookie_params([
    'path' => '/',
    'samesite' => 'Lax'
]);

if (isset($_GET['session_id']) && !empty($_GET['session_id'])) {
    session_id($_GET['session_id']);
}

session_start();

// Control de acceso unificado
if (!isset($_SESSION['usuari_ldap']) || empty($_SESSION['usuari_ldap'])) {
    header("Location: https://innovatetech-g3.ddns.net/login.php");
    exit();
}

// Variable auxiliar para marcar qué pestaña del menú está activa en cada página
$active_page = 'audio';

// [MANTENIDO] Persistencia estática para el histórico de diagnóstico
$archivo_datos_audio = __DIR__ . '/velocidad_audio.json';
if (file_exists($archivo_datos_audio) && filesize($archivo_datos_audio) > 0) {
    $datos_red = json_decode(file_get_contents($archivo_datos_audio), true);
    $audio_download = $datos_red['download'] ?? "Pendiente";
    $audio_upload = $datos_red['upload'] ?? "Pendiente";
    $audio_latency = $datos_red['ping'] ?? "Pendiente";
    $fecha_test_audio = $datos_red['ultima_actualizacion'] ?? "Ningún diagnóstico";
} else {
    $audio_download = "Pendiente";
    $audio_upload = "Pendiente";
    $audio_latency = "Pendiente";
    $fecha_test_audio = "Sin registros.";
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InnovateTech - Streaming Audio</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #00adb5;
            --primary-hover: #008c9e;
            --bg-dark: #1e1e24;
            --bg-header: #111116;
            --bg-card: #252530;
            --text-light: #f5f5f5;
            --text-muted: #a0a0b0;
            --danger: #ff2e63;
            --success: #00e676;
            --border-color: #3f3f52;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', 'Segoe UI', sans-serif; }

        body { background-color: var(--bg-dark); color: var(--text-light); display: flex; flex-direction: column; height: 100vh; overflow: hidden; }

        /* HEADER GLOBAL COMPACTADO A 70PX */
        header {
            background-color: var(--bg-header);
            padding: 0 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid var(--primary);
            height: 70px;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .logo h1 a { color: var(--primary); text-decoration: none; font-size: 24px; font-weight: bold; }
        .logo span { color: #fff; }

        /* HAMBURGUESA BUTTON */
        .menu-toggle {
            display: none;
            background: none;
            border: none;
            color: var(--text-light);
            font-size: 26px;
            cursor: pointer;
            padding: 5px;
            z-index: 1100;
        }

        /* NAVEGACIÓN CENTRAL (SERVICIOS) */
        #menu-servicios { display: flex; align-items: center; }
        .nav-services { display: flex; gap: 15px; list-style: none; flex-wrap: wrap; align-items: center; }
        .nav-services li { display: flex; align-items: center; }
        .nav-services a { color: var(--text-muted); text-decoration: none; font-weight: 500; font-size: 15px; padding: 8px 12px; border-radius: 5px; transition: 0.3s; border: 1px solid transparent; display: inline-flex; align-items: center; gap: 6px; }
        .nav-services a:hover, .nav-services a.active { color: var(--primary); background: rgba(0, 173, 181, 0.1); border-color: var(--primary); }

        /* CONTROL DE VISIBILIDAD DE DISPOSITIVOS */
        .mobile-only { display: none !important; }
        .desktop-only { display: inline-flex !important; }

        /* BLOQUE DE AUTENTICACIÓN (DERECHA) */
        .nav-auth { display: flex; align-items: center; gap: 15px; z-index: 1200; position: relative; }
        .user-logged { display: flex; align-items: center; gap: 10px; background: var(--bg-card); padding: 5px 15px; border-radius: 20px; border: 1px solid var(--border-color); font-size: 14px; white-space: nowrap; }
        .user-logged .user-icon { display: inline-block; }
        .user-role { background-color: #393e46; font-size: 11px; padding: 3px 8px; border-radius: 10px; text-transform: uppercase; color: var(--primary); font-weight: bold; }

        .btn-logout { color: var(--danger); text-decoration: none; font-size: 14px; font-weight: 600; transition: 0.3s; padding: 6px 12px; border-radius: 5px; border: 1px solid transparent; }
        .btn-logout:hover { border-color: var(--danger); background: rgba(255, 46, 99, 0.1); }

        .btn-panel-bd { display: flex; align-items: center; gap: 6px; background: var(--bg-card); color: var(--text-light); padding: 5px 15px; border-radius: 20px; border: 1px solid var(--primary); text-decoration: none; font-size: 13px; font-weight: 600; transition: 0.3s; }
        .btn-panel-bd:hover { background: rgba(0, 173, 181, 0.15); }

        /* ESTILOS DE BOTONES INTERNOS DE LA HAMBURGUESA EN MÓVIL */
        .nav-services .btn-db-mobile { border-color: var(--primary); color: var(--primary); width: 100%; justify-content: center; }
        .nav-services .btn-db-mobile:hover { background: var(--primary); color: #fff; }
        .nav-services .btn-logout-mobile { border-color: var(--danger); color: var(--danger); width: 100%; justify-content: center; }
        .nav-services .btn-logout-mobile:hover { background: var(--danger); color: #fff; }

        /* ESTRUCTURA INTERNA DEL REPRODUCTOR Y LA BARRA LATERAL */
        .wrapper-conferencia { width: 100%; height: calc(100vh - 70px); display: grid; grid-template-columns: 1fr 360px; background: #111116; }

        .audio-canvas { width: 100%; height: 100%; background: radial-gradient(circle at top, #222531 0%, #090a0f 100%); display: flex; align-items: center; justify-content: center; padding: 40px; }

        .spotify-player { background: #18181c; border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 16px; width: 100%; max-width: 420px; padding: 30px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6); text-align: center; }
        .album-cover-box { width: 240px; height: 240px; margin: 0 auto 25px auto; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); overflow: hidden; background: #282828; display: flex; align-items: center; justify-content: center; }
        .album-cover-box img { width: 100%; height: 100%; object-fit: cover; }

        .track-info h2 { font-size: 20px; color: #fff; margin-bottom: 6px; font-weight: 600; }
        .track-info p { font-size: 14px; color: var(--text-muted); margin-bottom: 30px; }

        .audio-element-box { background: #282828; border-radius: 30px; padding: 8px; margin-bottom: 20px; }
        audio { width: 100%; outline: none; }
        .badge-live { background: var(--danger); color: #fff; font-size: 10px; font-weight: 800; padding: 4px 10px; border-radius: 4px; display: inline-block; letter-spacing: 1px; }

        .sidebar-panel { background: var(--bg-header); border-left: 1px solid var(--border-color); padding: 25px; display: flex; flex-direction: column; gap: 25px; overflow-y: auto; }
        .sidebar-block h4 { font-size: 13px; color: #fff; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 15px; border-bottom: 1px solid var(--border-color); padding-bottom: 8px; }
        .metrics-list { list-style: none; }
        .metrics-list li { display: flex; justify-content: space-between; font-size: 14px; padding: 8px 0; border-bottom: 1px dashed var(--border-color); color: var(--text-muted); }
        .metrics-list span.val { color: #fff; font-weight: bold; }
        .metrics-list span.val.sc { color: var(--success); }

        .btn-speedtest { background-color: var(--primary); color: #fff; border: none; padding: 10px 14px; font-weight: 600; font-size: 12px; border-radius: 6px; cursor: pointer; width: 100%; text-transform: uppercase; margin-top: 12px; transition: 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 8px; }
        .btn-speedtest:hover { background-color: var(--primary-hover); }
        .btn-speedtest:disabled { background-color: #4a4a5a; color: var(--text-muted); cursor: not-allowed; }
        .spinner { width: 12px; height: 12px; border: 2px solid #fff; border-bottom-color: transparent; border-radius: 50%; display: none; animation: rotation 1s linear infinite; }
        @keyframes rotation { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

        .status-panel-mini { background: rgba(0, 173, 181, 0.05); border: 1px solid var(--primary); padding: 12px; border-radius: 6px; font-size: 12px; text-align: center; font-weight: 600; color: var(--primary); margin-top: 15px; }

        /* RESPONSIVE RESPIRABLE: SE ACTIVA CUANDO EL MENÚ VA A COLAPSAR */
        @media (max-width: 1150px) {
            header { padding: 0 20px; }
            .menu-toggle { display: block; }

            .desktop-only { display: none !important; }
            .mobile-only { display: flex !important; }

            .nav-auth { gap: 8px; }
            .user-logged { padding: 5px 10px; font-size: 13px; gap: 6px; }
            .user-logged .user-icon { display: none; }
            .user-role { font-size: 10px; padding: 2px 6px; }

            #menu-servicios {
                position: absolute;
                top: 70px;
                left: 0;
                width: 100%;
                background-color: var(--bg-header);
                padding: 20px;
                border-bottom: 2px solid var(--primary);
                box-shadow: 0 10px 20px rgba(0,0,0,0.5);
                opacity: 0;
                visibility: hidden;
                transform: translateY(-10px);
                transition: all 0.3s ease-in-out;
                z-index: 900;
            }

            #menu-servicios.active {
                opacity: 1;
                visibility: visible;
                transform: translateY(0);
            }

            .nav-services { flex-direction: column; width: 100%; gap: 10px; margin: 0; }
            .nav-services li { width: 100%; }
            .nav-services a { width: 100%; justify-content: center; padding: 12px; font-size: 16px; }

            .nav-services .divider {
                height: 1px;
                background-color: #3f3f52;
                width: 100%;
                margin: 10px 0;
                display: block;
                }

            .wrapper-conferencia { grid-template-columns: 1fr; height: calc(100vh - 70px); overflow-y: auto; }
            .sidebar-panel { border-left: none; border-top: 1px solid var(--border-color); }
        }
    </style>
</head>
<body>

    <header>
        <div class="logo">
            <h1><a href="https://innovatetech-g3.ddns.net/">Innovate<span>Tech</span></a></h1>
        </div>

        <nav id="menu-servicios">
            <ul class="nav-services">
                <li><a href="http://innovatech-g3.ddns.net/audio.php?session_id=<?php echo session_id(); ?>" class="<?php echo ($active_page == 'audio') ? 'active' : ''; ?>">📻 Streaming Audio</a></li>
                <li><a href="http://innovatech-g3.ddns.net/video.php?session_id=<?php echo session_id(); ?>" class="<?php echo ($active_page == 'video') ? 'active' : ''; ?>">📺 Contenido Video</a></li>
                <li><a href="http://32.199.24.67/videollamada.php?session_id=<?php echo session_id(); ?>" class="<?php echo ($active_page == 'jitsi') ? 'active' : ''; ?>">🌐 Videollamada Jitsi</a></li>

                <li>
                    <a href="https://github.com/ITB2526-PieroYcaza/ProyectoTransversal-Grupo3" target="_blank">
                        <svg width="14" height="14" fill="currentColor" viewBox="0 0 16 16" style="display: inline-block;">
                            <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27s1.36.09 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8"/>
                        </svg>
                        GitHub
                    </a>
                </li>

                <?php if (isset($_SESSION['mysql_user']) && $_SESSION['mysql_user'] === 'admin'): ?>
                    <li><a href="http://34.226.127.76:5601/" target="_blank">📊 Elastic</a></li>
                    <li><a href="http://18.235.254.161/lam" target="_blank">⚙️ LAM</a></li>
                <?php endif; ?>

                <?php if (isset($_SESSION['usuari_ldap'])): ?>
                    <li class="divider mobile-only"></li>
                    <?php if ($_SESSION['mysql_user'] !== 'cliente' && (!isset($_SESSION['gid_rol']) || (int)$_SESSION['gid_rol'] !== 3005)): ?>
                        <li class="mobile-only"><a href="https://innovatetech-g3.ddns.net/dashboard.php" class="btn-db-mobile">📊 Panel BD</a></li>
                    <?php endif; ?>
                    <li class="mobile-only"><a href="https://innovatetech-g3.ddns.net/logout.php" class="btn-logout-mobile">❌ Cerrar Sesión</a></li>
                <?php endif; ?>
            </ul>
        </nav>

        <div class="nav-auth">
            <?php if (isset($_SESSION['usuari_ldap'])): ?>
                <div class="user-logged">
                    <span class="user-icon">💻</span>
                    <span><strong><?php echo htmlspecialchars($_SESSION['usuari_ldap']); ?></strong></span>
                    <span class="user-role"><?php echo htmlspecialchars($_SESSION['mysql_user'] ?? 'Trabajador'); ?></span>
                </div>

                <?php if ($_SESSION['mysql_user'] !== 'cliente' && (!isset($_SESSION['gid_rol']) || (int)$_SESSION['gid_rol'] !== 3005)): ?>
                    <a href="https://innovatetech-g3.ddns.net/dashboard.php" class="btn-panel-bd desktop-only">📊 Panel BD</a>
                <?php endif; ?>

                <a href="https://innovatetech-g3.ddns.net/logout.php" class="btn-logout desktop-only">Cerrar Sesión</a>
            <?php endif; ?>

            <button class="menu-toggle" id="hamburguesa-btn" aria-label="Abrir menú">☰</button>
        </div>
    </header>

    <div class="wrapper-conferencia">
        <div class="audio-canvas">
            <div class="spotify-player">
                <div class="album-cover-box">
                    <img id="portada" src="https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300" alt="Portada de la Canción">
                </div>
                <div class="track-info">
                    <h2 id="titulo">Iniciando Sintonía...</h2>
                    <p id="artista">Conectando a Icecast</p>
                </div>
                <div class="audio-element-box">
                    <audio controls autoplay>
                        <source src="http://innovatech-g3.ddns.net:8000/stream" type="audio/mpeg">
                    </audio>
                </div>
                <span class="badge-live">● API SPOTIFY</span>
            </div>
        </div>

        <aside class="sidebar-panel">
            <div class="sidebar-block">
                <h4>Auditoría de Red Real</h4>
                <ul class="metrics-list">
                    <li>Descarga <span id="lbl-download" class="val sc"><?php echo $audio_download; ?></span></li>
                    <li>Subida <span id="lbl-upload" class="val sc"><?php echo $audio_upload; ?></span></li>
                    <li>Ping <span id="lbl-ping" class="val"><?php echo $audio_latency; ?></span></li>
                </ul>
                <button id="btn-lanzar" class="btn-speedtest" onclick="ejecutarSpeedtestReal()">
                    <span id="btn-spin" class="spinner"></span>
                    <span id="btn-texto">Lanzar Test</span>
                </button>
                <p style="font-size: 11px; color: var(--text-muted); margin-top: 10px; text-align: right; font-style: italic;">
                    Última prueba: <span id="lbl-fecha"><?php echo $fecha_test_audio; ?></span>
                </p>
                <div class="status-panel-mini">METADATOS: ONLINE</div>
            </div>
        </aside>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Lógica Menú Hamburguesa Responsivo
            const botonMenu = document.getElementById('hamburguesa-btn');
            const menuServicios = document.getElementById('menu-servicios');

            if (botonMenu && menuServicios) {
                botonMenu.addEventListener('click', function(e) {
                    e.stopPropagation();
                    menuServicios.classList.toggle('active');
                    botonMenu.textContent = menuServicios.classList.contains('active') ? '✕' : '☰';
                });

                document.addEventListener('click', function(e) {
                    if (!menuServicios.contains(e.target) && !botonMenu.contains(e.target)) {
                        menuServicios.classList.remove('active');
                        botonMenu.textContent = '☰';
                    }
                });
            }
        });

        // Configuración Metadatos Reproductor
        const CLIENT_ID = 'cb02791458fc4f629959963c6ae54ae6';
        const CLIENT_SECRET = '6d4913cfa1664d939ae4ffd298effeee';
        const ICECAST_URL = 'http://innovatech-g3.ddns.net:8000/status-json.xsl';

        let accessToken = "";
        let ultimoTextoBuscado = "";

        async function ejecutarSpeedtestReal() {
            const btn = document.getElementById('btn-lanzar');
            const spin = document.getElementById('btn-spin');
            const texto = document.getElementById('btn-texto');

            btn.disabled = true;
            spin.style.display = 'inline-block';
            texto.innerText = 'Calculando...';

            try {
                const respuesta = await fetch('ejecutar_test_live.php');
                const resultado = await respuesta.json();

                if(resultado.error) {
                    alert('Error en el servidor: ' + resultado.error);
                } else {
                    document.getElementById('lbl-download').innerText = resultado.download;
                    document.getElementById('lbl-upload').innerText = resultado.upload;
                    document.getElementById('lbl-ping').innerText = resultado.ping;
                    document.getElementById('lbl-fecha').innerText = resultado.ultima_actualizacion;
                }
            } catch (error) {
                console.error("Error ejecutando auditoría:", error);
                alert('No se pudo completar el test. Comprueba que speedtest-cli está instalado en AWS.');
            } finally {
                btn.disabled = false;
                spin.style.display = 'none';
                texto.innerText = 'Lanzar Test';
            }
        }

        async function obtenerToken() {
            try {
                const response = await fetch('https://accounts.spotify.com/api/token', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Authorization': 'Basic ' + btoa(CLIENT_ID + ':' + CLIENT_SECRET)
                    },
                    body: 'grant_type=client_credentials'
                });
                const data = await response.json();
                accessToken = data.access_token;
            } catch (error) {
                console.error("Error al obtener token de Spotify:", error);
            }
        }

        async function buscarEnSpotify(textoOriginal) {
            if (!accessToken) await obtenerToken();

            let textoLimpio = textoOriginal.replace(/[\s\n\r]+/g, ' ').trim();
            if (textoLimpio === ultimoTextoBuscado || textoLimpio === "-" || !textoLimpio) return;

            try {
                const urlBusqueda = 'https://api.spotify.com/v1/search?q=' + encodeURIComponent(textoLimpio) + '&type=track&limit=1';
                const response = await fetch(urlBusqueda, {
                    headers: { 'Authorization': 'Bearer ' + accessToken }
                });

                if (!response.ok) throw new Error("Fallo en la respuesta de Spotify");
                const data = await response.json();

                if (data.tracks && data.tracks.items.length > 0) {
                    const track = data.tracks.items[0];
                    ultimoTextoBuscado = textoLimpio;

                    document.getElementById('portada').src = track.album.images[0].url;
                    document.getElementById('titulo').innerText = track.name;
                    document.getElementById('artista').innerText = track.artists.map(a => a.name).join(', ');
                } else {
                    ultimoTextoBuscado = textoLimpio;
                    document.getElementById('titulo').innerText = textoLimpio;
                    document.getElementById('artista').innerText = "En directo";
                    document.getElementById('portada').src = "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300";
                }
            } catch (error) {
                console.error("Error buscando canción:", error);
                document.getElementById('titulo').innerText = textoLimpio;
                document.getElementById('artista').innerText = "Streaming Activo";
            }
        }

        async function actualizarReproductor() {
            try {
                const response = await fetch(ICECAST_URL);
                const text = await response.text();

                const coincidencia = text.match(/"title":\s*"([^"]+)"/i);
                let metadataTexto = "";

                if (coincidencia && coincidencia[1]) {
                    metadataTexto = coincidencia[1];
                }

                if (metadataTexto && metadataTexto !== "Innovate Tech Live" && metadataTexto !== "-") {
                    buscarEnSpotify(metadataTexto);
                }
            } catch (error) {
                console.error("Esperando datos del flujo...", error);
            }
        }

        actualizarReproductor();
        setInterval(actualizarReproductor, 3000);
    </script>
</body>
</html>