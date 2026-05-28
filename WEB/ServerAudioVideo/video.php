<?php
// FORZAR MODO DEPURACIÓN
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// INYECCIÓN DIRECTA DE CONFIGURACIÓN DE REDIS (Sesiones persistentes AWS)
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://54.197.85.133:6379?timeout=3');

// OBLIGATORIO: Configuración de cookies entre servidores del grupo 3
session_set_cookie_params([
    'path' => '/',
    'samesite' => 'Lax'
]);

// 1. CAPTURAMOS EL IDENTIFICADOR DE SESIÓN DE LA URL ANTES DE ARRANCAR
if (isset($_GET['session_id']) && !empty($_GET['session_id'])) {
    session_id($_GET['session_id']);
}

session_start();

// 2. CONTROL DE ACCESO CORPORATIVO - Actualizado a DNS
if (!isset($_SESSION['usuari_ldap']) || empty($_SESSION['usuari_ldap'])) {
    header("Location: https://innovatetech-g3.ddns.net/login.php");
    exit();
}

// Control de pestaña activa en el menú global
$active_page = 'video';

// 3. ESCANEO DEL DIRECTORIO DE VIDEOS LOCALES
$dir_videos = __DIR__ . '/videos/';
$videos_disponibles = [];
if (is_dir($dir_videos)) {
    if ($dh = opendir($dir_videos)) {
        while (($file = readdir($dh)) !== false) {
            if ($file != '.' && $file != '..' && pathinfo($file, PATHINFO_EXTENSION) == 'mp4') {
                $videos_disponibles[] = $file;
            }
        }
        closedir($dh);
    }
}

$video_actual = !empty($videos_disponibles) ? $videos_disponibles[0] : "";
if (isset($_GET['play']) && in_array($_GET['play'], $videos_disponibles)) {
    $video_actual = $_GET['play'];
}

// 4. Capa de persistencia estática para la carga inicial de la maqueta
$archivo_datos_video = __DIR__ . '/velocidad_video.json';

if (file_exists($archivo_datos_video) && filesize($archivo_datos_video) > 0) {
    $datos_red = json_decode(file_get_contents($archivo_datos_video), true);
    $video_download = $datos_red['download'] ?? "Pendiente";
    $video_upload = $datos_red['upload'] ?? "Pendiente";
    $video_ping = $datos_red['ping'] ?? "Pendiente";
    $fecha_test_video = $datos_red['ultima_actualizacion'] ?? "Ningún diagnóstico registrado";
} else {
    $video_download = "Pendiente";
    $video_upload = "Pendiente";
    $video_ping = "Pendiente";
    $fecha_test_video = "Sin registros. Inicie el test de alta carga multimedia.";
}

function obtenerFotogramaDeVideo($video_name, $dir) {
    $nombre_limpio = pathinfo($video_name, PATHINFO_FILENAME);
    $ruta_video = $dir . $video_name;
    $ruta_miniatura = $dir . $nombre_limpio . ".jpg";

    if (file_exists($ruta_miniatura)) {
        return "http://innovatech-g3.ddns.net/videos/" . rawurlencode($nombre_limpio . ".jpg");
    }

    $comando = "ffmpeg -ss 00:00:05 -i " . escapeshellarg($ruta_video) . " -vframes 1 -q:v:2 " . escapeshellarg($ruta_miniatura) . " 2>&1";
    exec($comando, $output, $return_var);

    return ($return_var === 0 && file_exists($ruta_miniatura)) ? "http://innovatech-g3.ddns.net/videos/" . rawurlencode($nombre_limpio . ".jpg") : "";
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InnovateTech - Servicio de Video Bajo Demanda (VOD)</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #00adb5;
            --primary-hover: #008c9e;
            --bg-dark: #1a1a20;
            --bg-header: #111116;
            --bg-card: #252530;
            --text-light: #f5f5f5;
            --text-muted: #a0a0b0;
            --danger: #ff2e63;
            --success: #00e676;
            --border-color: #3f3f52;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', 'Segoe UI', sans-serif; }
        body { background-color: var(--bg-dark); color: var(--text-light); line-height: 1.6; }

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

        /* CONTENIDO MULTIMEDIA Y BLOQUES VOD */
        .hero { padding: 30px 40px; background: linear-gradient(135deg, var(--bg-header) 0%, #222831 100%); border-bottom: 1px solid #2a2a35; display: flex; justify-content: space-between; align-items: center; gap: 30px; }
        .hero-text { max-width: 70%; }
        .hero h2 { font-size: 28px; margin-bottom: 5px; color: #fff; }
        .hero p { font-size: 14px; color: var(--text-muted); }

        .cluster-status { display: flex; gap: 15px; background: rgba(0, 0, 0, 0.3); padding: 12px 20px; border-radius: 12px; border: 1px solid var(--border-color); flex-shrink: 0; }
        .cluster-status .status-item { text-align: center; }
        .status-item .title { font-size: 11px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; }
        .status-item .value { font-size: 13px; font-weight: 700; color: var(--success); margin-top: 2px; }

        .layout-container { max-width: 1400px; margin: 40px auto; padding: 0 40px; display: grid; grid-template-columns: 1fr 360px; gap: 30px; }
        .section-title { font-size: 20px; margin-bottom: 20px; color: var(--primary); border-left: 4px solid var(--primary); padding-left: 15px; font-weight: 600; }

        .theater-mode { background-color: var(--bg-header); border-radius: 12px; padding: 20px; border: 1px solid var(--border-color); margin-bottom: 40px; box-shadow: 0 10px 25px rgba(0,0,0,0.4); }
        video { width: 100%; max-height: 480px; border-radius: 8px; background: #000; display: block; margin: 0 auto; }
        .current-video-info { margin-top: 15px; padding-top: 15px; border-top: 1px solid #2a2a35; }
        .current-video-title { font-size: 18px; color: #fff; font-weight: 600; }
        .current-video-meta { font-size: 13px; color: var(--primary); margin-top: 5px; }

        .youtube-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; }
        .video-card-yt { text-decoration: none; color: inherit; display: flex; flex-direction: column; cursor: pointer; transition: transform 0.2s; }
        .video-card-yt:hover { transform: scale(1.02); }
        .thumbnail-container { width: 100%; aspect-ratio: 16/9; background: linear-gradient(135deg, #2a2a35 0%, var(--bg-header) 100%); border-radius: 12px; border: 1px solid var(--border-color); display: flex; align-items: center; justify-content: center; position: relative; overflow: hidden; }
        .thumbnail-img { width: 100%; height: 100%; object-fit: cover; }

        .video-details { display: flex; gap: 12px; margin-top: 12px; }
        .channel-avatar { width: 34px; height: 34px; background-color: #393e46; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary); font-size: 12px; flex-shrink: 0; border: 1px solid var(--border-color); }
        .video-text { display: flex; flex-direction: column; overflow: hidden; }
        .video-title-text { font-size: 14px; font-weight: 600; color: #f5f5f5; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .video-author { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

        .sidebar-panel { background: var(--bg-header); border: 1px solid var(--border-color); border-radius: 12px; padding: 25px; height: fit-content; }
        .sidebar-block { margin-bottom: 25px; }
        .sidebar-block h4 { font-size: 12px; color: #fff; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 15px; border-bottom: 1px solid var(--border-color); padding-bottom: 8px; }

        .metrics-list { list-style: none; }
        .metrics-list li { display: flex; justify-content: space-between; font-size: 14px; padding: 8px 0; border-bottom: 1px dashed var(--border-color); color: var(--text-muted); }
        .metrics-list span.val { color: #fff; font-weight: bold; }
        .metrics-list span.val.sc { color: var(--success); }

        .btn-speedtest { background-color: var(--primary); color: #fff; border: none; padding: 10px 14px; font-weight: 600; font-size: 12px; border-radius: 6px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; text-transform: uppercase; width: 100%; justify-content: center; margin-top: 12px; transition: 0.2s; }
        .btn-speedtest:hover { background-color: var(--primary-hover); }
        .btn-speedtest:disabled { background-color: #4a4a5a; color: var(--text-muted); cursor: not-allowed; }
        .spinner { width: 12px; height: 12px; border: 2px solid #fff; border-bottom-color: transparent; border-radius: 50%; display: none; animation: rotation 1s linear infinite; }
        @keyframes rotation { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

        .status-panel-mini { background: rgba(0, 230, 118, 0.05); border: 1px solid var(--success); padding: 12px; border-radius: 6px; font-size: 12px; text-align: center; font-weight: 600; color: var(--success); margin-top: 15px; }
        footer { background-color: var(--bg-header); text-align: center; padding: 20px; color: #666; font-size: 13px; border-top: 1px solid #2a2a35; margin-top: 60px; }

        /* RESPONSIVE RESPIRABLE: DISPOSITIVOS MÓVILES Y ADAPTACIÓN DE LAYOUT */
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

            .hero { flex-direction: column; text-align: center; padding: 20px; }
            .hero-text { max-width: 100%; }
            .cluster-status { width: 100%; justify-content: dashed; justify-content: center; }

            .layout-container { grid-template-columns: 1fr; padding: 0 20px; margin: 20px auto; gap: 25px; }
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
                    <span>
        <strong><?php echo htmlspecialchars($_SESSION['usuari_ldap']); ?></strong>
                </span>
                <span class="user-role"><?php echo htmlspecialchars($_SESSION['mysql_user'] ?? 'Trabajador'); ?></span>
            </div>

            <?php if ($_SESSION['mysql_user'] !== 'cliente' && (!isset($_SESSION['gid_rol']) || (int)$_SESSION['gid_rol'] !== 3005)): ?>
                <a href="https://innovatetech-g3.ddns.net/dashboard.php" class="btn-panel-bd desktop-only">📊 Panel BD</a>
            <?php endif; ?>

            <a href="https://innovatetech-g3.ddns.net/logout.php" class="btn-logout desktop-only">Cerrar Sesión</a>
        <?php endif; ?>

        <button class="menu-toggle" id="btn-hamburguesa" aria-label="Abrir menú" onclick="conmutarMenuMovil()">☰</button>
    </div>
</header>

<div class="hero">
    <div class="hero-text">
        <h2>Repositorio VOD Multipunto</h2>
        <p>Plataforma de alta disponibilidad para la distribución de contenido multimedia bajo demanda.</p>
    </div>
    <div class="cluster-status">
        <div class="status-item">
            <div class="title">Nodo VOD</div>
            <div class="value">Online</div>
        </div>
        <div class="status-item">
            <div class="title">Capa FFMPEG</div>
            <div class="value" style="color: var(--primary);">Activa</div>
        </div>
    </div>
</div>

<div class="layout-container">

    <main>
        <?php if (!empty($video_actual)): ?>
            <div class="theater-mode">
                <video controls autoplay poster="<?php echo obtenerFotogramaDeVideo($video_actual, $dir_videos); ?>">
                    <source src="videos/<?php echo rawurlencode($video_actual); ?>" type="video/mp4">
                    Tu navegador no soporta el elemento de video.
                </video>
                <div class="current-video-info">
                    <div class="current-video-title"><?php echo htmlspecialchars(pathinfo($video_actual, PATHINFO_FILENAME)); ?></div>
                    <div class="current-video-meta">Reproduciendo desde almacenamiento EC2 dedicado</div>
                </div>
            </div>
        <?php endif; ?>

        <h3 class="section-title">Videos Disponibles en el Servidor</h3>
        <div class="youtube-grid">
            <?php foreach ($videos_disponibles as $video):
                $miniatura = obtenerFotogramaDeVideo($video, $dir_videos);
                $clase_activa = ($video === $video_actual) ? 'active' : '';
            ?>
                <a href="?session_id=<?php echo session_id(); ?>&play=<?php echo rawurlencode($video); ?>" class="video-card-yt <?php echo $clase_activa; ?>">
                    <div class="thumbnail-container">
                        <?php if (!empty($miniatura)): ?>
                            <img class="thumbnail-img" src="<?php echo $miniatura; ?>" alt="Miniatura">
                        <?php else: ?>
                            <span style="font-size: 24px;">🎬</span>
                        <?php endif; ?>
                    </div>
                    <div class="video-details">
                        <div class="channel-avatar">IT</div>
                        <div class="video-text">
                            <div class="video-title-text"><?php echo htmlspecialchars(pathinfo($video, PATHINFO_FILENAME)); ?></div>
                            <div class="video-author">InnovateTech VOD</div>
                        </div>
                    </div>
                </a>
            <?php endforeach; ?>
        </div>
    </main>

    <aside class="sidebar-panel">
        <div class="sidebar-block">
            <h4>Auditoría de Red Real</h4>
            <ul class="metrics-list">
                <li>Descarga <span id="lbl-download" class="val sc"><?php echo $video_download; ?></span></li>
                <li>Subida <span id="lbl-upload" class="val sc"><?php echo $video_upload; ?></span></li>
                <li>Ping <span id="lbl-ping" class="val"><?php echo $video_ping; ?></span></li>
            </ul>
            <button id="btn-lanzar" class="btn-speedtest" onclick="ejecutarSpeedtestReal()">
                <span id="btn-spin" class="spinner"></span>
                <span id="btn-texto">Lanzar Test</span>
            </button>
            <p style="font-size: 11px; color: var(--text-muted); margin-top: 10px; text-align: right; font-style: italic;">
                Última prueba: <span id="lbl-fecha"><?php echo $fecha_test_video; ?></span>
            </p>
            <div class="status-panel-mini">NODO LIVE: SIN CONGESTIÓN</div>
        </div>
    </aside>

</div>

<footer>
    &copy; 2026 InnovateTech - Entorno Multimedia Integrado con OpenLDAP & Redis Security.
</footer>

<script>
    // Gestión del comportamiento interactivo responsivo del Menú Hamburguesa
    function conmutarMenuMovil() {
        const menu = document.getElementById('menu-servicios');
        const boton = document.getElementById('btn-hamburguesa');

        menu.classList.toggle('active');

        if (menu.classList.contains('active')) {
            boton.innerText = '✕';
        } else {
            boton.innerText = '☰';
        }
    }

    // Cerrar el menú si se hace click fuera de él mientras está desplegado
    document.addEventListener('click', function(evento) {
        const menu = document.getElementById('menu-servicios');
        const boton = document.getElementById('btn-hamburguesa');

        if (!menu.contains(evento.target) && !boton.contains(evento.target) && menu.classList.contains('active')) {
            menu.classList.remove('active');
            boton.innerText = '☰';
        }
    });

    // Petición asíncrona hacia el nodo de cálculo para auditoría de red multimedia
    async function ejecutarSpeedtestReal() {
        const btn = document.getElementById('btn-lanzar');
        const spin = document.getElementById('btn-spin');
        const texto = document.getElementById('btn-texto');

        btn.disabled = true;
        spin.style.display = 'inline-block';
        texto.innerText = 'Calculando...';

        try {
            const respuesta = await fetch('ejecutar_test_live.php?session_id=<?php echo session_id(); ?>');
            const resultado = await respuesta.json();

            if(resultado.error) {
                alert('Error de Seguridad: ' + resultado.error);
            } else {
                document.getElementById('lbl-download').innerText = resultado.download;
                document.getElementById('lbl-upload').innerText = resultado.upload;
                document.getElementById('lbl-ping').innerText = resultado.ping || "N/A";
                document.getElementById('lbl-fecha').innerText = resultado.ultima_actualizacion;
            }
        } catch (error) {
            console.error("Error ejecutando auditoría:", error);
            alert('No se pudo mapear la respuesta JSON del nodo de cálculo.');
        } finally {
            btn.disabled = false;
            spin.style.display = 'none';
            texto.innerText = 'Lanzar Test';
        }
    }
</script>
</body>
</html>