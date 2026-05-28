<?php
// Forzamos a la portada a usar la IP accesible por el clúster de AWS
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://54.197.85.133:6379?timeout=3');

// OBLIGATORIO: Configuramos las cookies para que sean válidas al saltar entre los servidores
session_set_cookie_params([
    'path' => '/',
    'samesite' => 'Lax'
]);
session_start();

// Control de acceso: si no viene rebotado del LDAP, patada al login institucional
if (!isset($_SESSION['usuari_ldap']) || !isset($_SESSION['mysql_user'])) {
    header("Location: https://innovatetech-g3.ddns.net/login.php");
    exit();
}

$active_page = 'dashboard';

$db_host = "172.31.30.119";
$db_user = $_SESSION['mysql_user'];
$db_pass = $_SESSION['mysql_pass'];
$db_name = "innovate_tech_db";

// 1. CONEXIÓN A MYSQL CON EL ROL ASIGNADO POR LDAP
mysqli_report(MYSQLI_REPORT_OFF);
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    die("Error crític de connexió a la Base de Dades amb el rol '" . htmlspecialchars($db_user) . "': " . $conn->connect_error);
}

$es_treballador = ($db_user === 'treballador');

// ============================================================================
// 2. MATRIZ DE VISIBILIDAD ESTRICTA SEGÚN ROL
// ============================================================================
$matriz_permisos = [
    'admin' => [
        'clients', 'comandes', 'productes', 'cistell', 'registre_trucades',
        'empleats', 'nominas', 'departaments', 'grup_nivell',
        'cataleg_videos', 'configuracio_qualitat', 'usuaris_sistema',
        'servidors_videoconferencia', 'taula_avisos', 'rols_ldap'
    ],
    'vendes' => [
        'clients', 'comandes', 'productes', 'cistell', 'registre_trucades'
    ],
    'administracio' => [
        'empleats', 'nominas', 'departaments', 'grup_nivell'
    ],
    'treballador' => [
        'productes', 'cataleg_videos', 'registre_trucades'
    ]
];

$todas_las_tablas = isset($matriz_permisos[$db_user]) ? $matriz_permisos[$db_user] : [];
$tabla_activa = isset($_GET['tabla']) ? $_GET['tabla'] : (count($todas_las_tablas) > 0 ? $todas_las_tablas[0] : null);

if ($tabla_activa && !in_array($tabla_activa, $todas_las_tablas)) {
    die("⚠️ Error de Seguretat: El teu rol no té permisos sobre la taula '" . htmlspecialchars($tabla_activa) . "'.");
}

$columnas = [];
$filas = [];
$pk_campo = null;

if ($tabla_activa) {
    $res_cols = $conn->query("SHOW COLUMNS FROM `$tabla_activa`");
    if ($res_cols) {
        while ($col = $res_cols->fetch_assoc()) {
            $columnas[] = $col['Field'];
            if ($col['Key'] === 'PRI') {
                $pk_campo = $col['Field'];
            }
        }
    }
    $res_filas = $conn->query("SELECT * FROM `$tabla_activa` LIMIT 50");
    if ($res_filas) {
        while ($fila = $res_filas->fetch_assoc()) {
            $filas[] = $fila;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InnovateTech - Panell de Control</title>
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
        body { background-color: var(--bg-dark); color: var(--text-light); display: flex; flex-direction: column; min-height: 100vh; }

        /* HEADER GLOBAL */
        header { background-color: var(--bg-header); padding: 0 40px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid var(--primary); height: 70px; position: sticky; top: 0; z-index: 1000; width: 100%; }
        .logo h1 a { color: var(--primary); text-decoration: none; font-size: 24px; font-weight: bold; }
        .logo span { color: #fff; }

        .menu-toggle { display: none; background: none; border: none; color: var(--text-light); font-size: 26px; cursor: pointer; padding: 5px; z-index: 1100; }
        #menu-servicios { display: flex; align-items: center; }
        .nav-services { display: flex; gap: 15px; list-style: none; align-items: center; }
        .nav-services a { color: var(--text-muted); text-decoration: none; font-weight: 500; font-size: 15px; padding: 8px 12px; border-radius: 5px; transition: 0.3s; display: inline-flex; align-items: center; gap: 6px; }
        .nav-services a:hover, .nav-services a.active { color: var(--primary); background: rgba(0, 173, 181, 0.1); border-color: var(--primary); }

        .mobile-only { display: none !important; }
        .desktop-only { display: inline-flex !important; }

        .nav-auth { display: flex; align-items: center; gap: 15px; }
        .user-logged { display: flex; align-items: center; gap: 10px; background: var(--bg-card); padding: 5px 15px; border-radius: 20px; border: 1px solid var(--border-color); font-size: 14px; }
        .user-role { background-color: #393e46; font-size: 11px; padding: 3px 8px; border-radius: 10px; text-transform: uppercase; color: var(--primary); font-weight: bold; }
        .btn-logout { color: var(--danger); text-decoration: none; font-size: 14px; font-weight: 600; transition: 0.3s; padding: 6px 12px; border-radius: 5px; }
        .btn-logout:hover { background: rgba(255, 46, 99, 0.1); }

        /* INTERFÍCIE WRAPPER */
        .dashboard-wrapper { display: flex; flex: 1; width: 100%; }

        /* SIDEBAR LATERAL (DESPLEGABLE EN MÒBIL) */
        sidebar { width: 280px; background-color: var(--bg-header); border-right: 2px solid var(--primary); padding: 25px 15px; display: flex; flex-direction: column; flex-shrink: 0; transition: all 0.3s ease; }
        .sidebar-title { color: var(--primary); font-size: 18px; font-weight: bold; margin-bottom: 5px; text-align: center; }
        .sidebar-subtitle { color: var(--text-muted); font-size: 11px; text-align: center; margin-bottom: 25px; text-transform: uppercase; letter-spacing: 1px; }

        /* Botó col·lapsable invisible en Desktop, actiu en mòbil */
        .menu-label { font-size: 12px; color: var(--primary); font-weight: bold; text-transform: uppercase; margin-bottom: 12px; padding-left: 10px; display: flex; justify-content: space-between; align-items: center; }

        .table-list { list-style: none; display: flex; flex-direction: column; gap: 8px; flex-grow: 1; transition: max-height 0.3s ease-in-out; }
        .table-item a { display: block; padding: 11px 14px; background-color: var(--bg-card); border-radius: 5px; color: #b5b5c3; text-decoration: none; font-size: 14px; font-weight: 600; border: 1px solid transparent; transition: 0.2s; }
        .table-item a:hover { background-color: #31313d; color: #fff; border-color: var(--border-color); }
        .table-item.active a { background-color: rgba(0, 173, 181, 0.15); color: var(--primary); border-color: var(--primary); }

        .btn-back-home { display: block; text-align: center; background-color: #393e46; color: #fff; padding: 10px; border-radius: 5px; text-decoration: none; font-size: 14px; font-weight: bold; margin-top: 20px; }

        /* PRINCIPAL */
        main { flex-grow: 1; padding: 40px; background-color: var(--bg-dark); overflow-x: hidden; }
        .top-bar { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 20px; margin-bottom: 30px; gap: 20px; }
        .panel-badge-container { display: flex; align-items: center; gap: 12px; background-color: var(--bg-header); padding: 10px 20px; border-radius: 30px; border: 1px solid var(--border-color); font-size: 14px; }
        .role-tag { background-color: var(--primary); color: #fff; padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .mode-tag { background-color: var(--danger); color: #fff; padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .mode-tag.read { background-color: var(--success); color: #111; }

        /* TAULA COMPONENT */
        .table-header-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; gap: 15px; flex-wrap: wrap; }
        .table-title { font-size: 20px; color: #fff; }
        .btn-add { background-color: var(--primary); color: #fff; padding: 10px 18px; border-radius: 4px; text-decoration: none; font-size: 14px; font-weight: bold; transition: 0.3s; }
        .btn-add.disabled { background-color: #444; color: #777; cursor: not-allowed; pointer-events: none; }

        .table-responsive { width: 100%; overflow-x: auto; background-color: var(--bg-header); border-radius: 8px; border: 1px solid var(--border-color); box-shadow: 0 4px 15px rgba(0,0,0,0.4); }
        .data-table { width: 100%; border-collapse: collapse; text-align: left; font-size: 14px; white-space: nowrap; }
        .data-table th { background-color: #17171f; color: var(--primary); padding: 16px; border-bottom: 2px solid var(--border-color); font-weight: 600; text-transform: uppercase; font-size: 12px; }
        .data-table td { padding: 16px; border-bottom: 1px solid var(--border-color); color: #e1e1e6; }
        .data-table tr:hover { background-color: #181822; }
        .no-data { padding: 40px; text-align: center; color: var(--text-muted); font-style: italic; }
        .action-links { color: var(--primary); text-decoration: none; font-weight: bold; margin-right: 12px; }
        .action-links.delete { color: var(--danger); }

        /* RESPONSIVE MEDIA QUERIES */
        @media (max-width: 1024px) {
            header { padding: 0 20px; }
            .menu-toggle { display: block; }
            .desktop-only { display: none !important; }
            .mobile-only { display: flex !important; }

            #menu-servicios { position: absolute; top: 70px; left: 0; width: 100%; background-color: var(--bg-header); padding: 20px; border-bottom: 2px solid var(--primary); opacity: 0; visibility: hidden; transform: translateY(-10px); transition: all 0.3s ease-in-out; z-index: 1500; }
            #menu-servicios.active { opacity: 1; visibility: visible; transform: translateY(0); }
            .nav-services { flex-direction: column; width: 100%; gap: 10px; }
            .nav-services li { width: 100%; }
            .nav-services a { width: 100%; justify-content: center; padding: 12px; }
            .nav-services .divider { height: 1px; background-color: #3f3f52; width: 100%; margin: 10px 0; }
            .nav-services .btn-logout-mobile { border: 1px solid var(--danger); color: var(--danger); }

            /* TRANSFORMACIÓ BARRA LATERAL A DESPLEGABLE / ACORDIÓ */
            .dashboard-wrapper { flex-direction: column; }
            sidebar { width: 100%; border-right: none; border-bottom: 2px solid var(--primary); padding: 15px; }
            .sidebar-title, .sidebar-subtitle { display: none; } /* Ocultem títols duplicats */

            .menu-label { cursor: pointer; margin-bottom: 0; padding: 10px; background: var(--bg-card); border-radius: 5px; border: 1px solid var(--border-color); }
            .menu-label::after { content: ' ▾'; font-size: 14px; transition: transform 0.3s; }
            .menu-label.open::after { content: ' ▴'; }

            .table-list { max-height: 0; overflow: hidden; gap: 5px; margin-top: 0; transition: max-height 0.3s ease-out, margin-top 0.3s; }
            .table-list.open { max-height: 300px; overflow-y: auto; margin-top: 10px; padding-bottom: 5px; }

            main { padding: 20px 15px; }
            .top-bar { flex-direction: column; align-items: flex-start; gap: 12px; }
            .panel-badge-container { width: 100%; justify-content: space-between; }
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
                <li><a href="http://innovatech-g3.ddns.net/audio.php?session_id=<?php echo session_id(); ?>">📻 Streaming Audio</a></li>
                <li><a href="http://innovatech-g3.ddns.net/video.php?session_id=<?php echo session_id(); ?>">📺 Contenido Video</a></li>
                <li><a href="http://innovatech-g3.ddns.net/videollamada.php?session_id=<?php echo session_id(); ?>">🌐 Videollamada Jitsi</a></li>
                <li>
                    <a href="https://github.com/ITB2526-PieroYcaza/ProyectoTransversal-Grupo3" target="_blank">
                        <svg width="14" height="14" fill="currentColor" viewBox="0 0 16 16" style="display: inline-block;"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27s1.36.09 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8"/></svg>
                        GitHub
                    </a>
                </li>
                <?php if (isset($_SESSION['mysql_user']) && $_SESSION['mysql_user'] === 'admin'): ?>
                    <li><a href="http://34.226.127.76:5601/" target="_blank">📊 Elastic</a></li>
                    <li><a href="http://18.235.254.161/lam" target="_blank">⚙️ LAM</a></li>
                <?php endif; ?>
                <?php if (isset($_SESSION['usuari_ldap'])): ?>
                    <li class="divider mobile-only"></li>
                    <li class="mobile-only"><a href="https://innovatetech-g3.ddns.net/logout.php" class="btn-logout-mobile">❌ Cerrar Sesión</a></li>
                <?php endif; ?>
            </ul>
        </nav>

        <div class="nav-auth">
            <?php if (isset($_SESSION['usuari_ldap'])): ?>
                <div class="user-logged">
                    <span><strong><?php echo htmlspecialchars($_SESSION['usuari_ldap']); ?></strong></span>
                    <span class="user-role"><?php echo htmlspecialchars($_SESSION['mysql_user'] ?? 'Trabajador'); ?></span>
                </div>
                <a href="https://innovatetech-g3.ddns.net/logout.php" class="btn-logout desktop-only">Cerrar Sesión</a>
            <?php endif; ?>
            <button class="menu-toggle" id="btn-hamburguesa" onclick="conmutarMenuMovil()">☰</button>
        </div>
    </header>

    <div class="dashboard-wrapper">
        <sidebar>
            <div class="sidebar-title">InnovateTech</div>
            <div class="sidebar-subtitle">Gestor Relacional</div>

            <div class="menu-label" id="accordion-toggle" onclick="toggleSidebarMenu()">Taules Permeses</div>

            <ul class="table-list" id="sidebar-tables">
                <?php if (empty($todas_las_tablas)): ?>
                    <li style="color:var(--text-muted); font-size:13px; font-style:italic; padding-left:10px;">Cap taula accessible.</li>
                <?php else: ?>
                    <?php foreach ($todas_las_tablas as $tbl): ?>
                        <li class="table-item <?php echo ($tbl === $tabla_activa) ? 'active' : ''; ?>">
                            <a href="dashboard.php?session_id=<?php echo session_id(); ?>&tabla=<?php echo urlencode($tbl); ?>">
                                📁 <?php echo htmlspecialchars($tbl); ?>
                            </a>
                        </li>
                    <?php endforeach; ?>
                <?php endif; ?>
            </ul>

            <a href="http://innovatech-g3.ddns.net/video.php?session_id=<?php echo session_id(); ?>" class="btn-back-home">← Tornar a l'Inici</a>
        </sidebar>

        <main>
            <div class="top-bar">
                <h2>Panell de Control Operatiu</h2>
                <div class="panel-badge-container">
                    <span>👤 <strong><?php echo htmlspecialchars($_SESSION['usuari_ldap']); ?></strong></span>
                    <span class="role-tag">MySQL: <?php echo htmlspecialchars($db_user); ?></span>
                    <span class="mode-tag <?php echo $es_treballador ? '' : 'read'; ?>">
                        <?php echo $es_treballador ? 'Lectura Estricta' : 'Lectura i Escriptura'; ?>
                    </span>
                </div>
            </div>

            <?php if ($tabla_activa): ?>
                <div class="table-header-container">
                    <h3 class="table-title">Dades de la taula: <u><?php echo htmlspecialchars($tabla_activa); ?></u></h3>
                    <?php if ($es_treballador): ?>
                        <a href="#" class="btn-add disabled" onclick="return false;">＋ Inserir Registre (Capat)</a>
                    <?php else: ?>
                        <a href="insertar.php?session_id=<?php echo session_id(); ?>&tabla=<?php echo urlencode($tabla_activa); ?>" class="btn-add">＋ Inserir Nou Registre</a>
                    <?php endif; ?>
                </div>

                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <?php foreach ($columnas as $col): ?>
                                    <th><?php echo htmlspecialchars($col); ?></th>
                                <?php endforeach; ?>
                                <?php if (!$es_treballador): ?>
                                    <th>Accions</th>
                                <?php endif; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($filas)): ?>
                                <tr>
                                    <td colspan="<?php echo count($columnas) + ($es_treballador ? 0 : 1); ?>" class="no-data">Aquesta taula no conté cap registre.</td>
                                </tr>
                            <?php else: ?>
                                <?php foreach ($filas as $fila): ?>
                                    <tr>
                                        <?php foreach ($columnas as $col): ?>
                                            <td><?php echo htmlspecialchars($fila[$col] ?? 'NULL'); ?></td>
                                        <?php endforeach; ?>
                                        <?php if (!$es_treballador): ?>
                                            <td>
                                                <?php if ($pk_campo && isset($fila[$pk_campo])): ?>
                                                    <a href="editar.php?session_id=<?php echo session_id(); ?>&tabla=<?php echo urlencode($tabla_activa); ?>&id=<?php echo urlencode($fila[$pk_campo]); ?>" class="action-links">Editar</a>
                                                    <a href="eliminar.php?session_id=<?php echo session_id(); ?>&tabla=<?php echo urlencode($tabla_activa); ?>&id=<?php echo urlencode($fila[$pk_campo]); ?>" class="action-links delete">Borrar</a>
                                                <?php else: ?>
                                                    <span style="color: var(--text-muted); font-style: italic; font-size: 12px;">Sense PK</span>
                                                <?php endif; ?>
                                            </td>
                                        <?php endif; ?>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            <?php else: ?>
                <div style="background-color: var(--bg-header); padding: 40px; border-radius: 8px; text-align: center; border: 1px solid var(--border-color);">
                    <p style="color: var(--text-muted);">S'ha iniciat la sessió correctament, sense taules assignades.</p>
                </div>
            <?php endif; ?>
        </main>
    </div>

    <script>
        // Hamburguesa del Header General
        function conmutarMenuMovil() {
            const menu = document.getElementById('menu-servicios');
            const boton = document.getElementById('btn-hamburguesa');
            menu.classList.toggle('active');
            boton.innerText = menu.classList.contains('active') ? '✕' : '☰';
        }

        // Desplegable Acordió de la llista de Taules (Sidebar Mòbil)
        function toggleSidebarMenu() {
            if (window.innerWidth <= 1024) {
                const label = document.getElementById('accordion-toggle');
                const list = document.getElementById('sidebar-tables');
                label.classList.toggle('open');
                list.classList.toggle('open');
            }
        }
    </script>
</body>
</html>
<?php $conn->close(); ?>