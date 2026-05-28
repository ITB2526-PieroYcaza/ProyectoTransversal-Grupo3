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
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InnovateTech - Portal Corporativo y Gestión de Sistemas</title>
    <style>
        :root {
            --primary: #00adb5;
            --primary-hover: #008c9e;
            --bg-dark: #1a1a20;
            --bg-header: #111116;
            --bg-card: #252530;
            --bg-card-hover: #2d2d3a;
            --text-light: #f5f5f5;
            --text-muted: #a0a0b0;
            --danger: #ff2e63;
            --success: #00e676;
            --warning: #ffea00;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: var(--bg-dark); color: var(--text-light); line-height: 1.6; }

        /* HEADER */
        header {
            background-color: var(--bg-header);
            padding: 15px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid var(--primary);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .logo h1 { color: var(--primary); font-size: 24px; font-weight: bold; }
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
        .nav-services { display: flex; gap: 15px; list-style: none; flex-wrap: wrap; margin: 10px 0; align-items: center; }
        .nav-services li { display: flex; align-items: center; }
        .nav-services a { color: var(--text-muted); text-decoration: none; font-weight: 500; font-size: 15px; transition: 0.3s; padding: 8px 12px; border-radius: 5px; border: 1px solid transparent; display: inline-flex; align-items: center; gap: 6px; }
        .nav-services a:hover, .nav-services a.active { color: var(--primary); background: rgba(0, 173, 181, 0.1); border-color: var(--primary); }

        /* CONTROL DE VISIBILIDAD */
        .mobile-only { display: none !important; }
        .desktop-only { display: inline-flex !important; }

        /* BLOQUE DE AUTENTICACIÓN (DERECHA) */
        .nav-auth {
            display: flex;
            align-items: center;
            gap: 15px;
            z-index: 1200;
            position: relative;
        }
        .btn-login { background-color: var(--primary); color: #fff; padding: 8px 18px; border-radius: 5px; text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 8px; transition: 0.3s; }
        .btn-login:hover { background-color: var(--primary-hover); }

        .user-logged { display: flex; align-items: center; gap: 10px; background: var(--bg-card); padding: 6px 15px; border-radius: 20px; border: 1px solid #3f3f52; white-space: nowrap; }
        .user-logged .user-icon { display: inline-block; }
        .user-role { background-color: #393e46; font-size: 11px; padding: 3px 8px; border-radius: 10px; text-transform: uppercase; color: var(--primary); font-weight: bold; }

        .btn-logout { color: var(--danger); text-decoration: none; font-size: 14px; font-weight: 600; transition: 0.3s; padding: 6px 12px; border-radius: 5px; border: 1px solid transparent; }
        .btn-logout:hover { border-color: var(--danger); background: rgba(255, 46, 99, 0.1); }

        .btn-db { background-color: #393e46; color: var(--text-light); padding: 6px 12px; border-radius: 5px; text-decoration: none; font-size: 13px; font-weight: 600; border: 1px solid var(--primary); transition: 0.3s; }
        .btn-db:hover { background-color: var(--primary); color: #fff; }

        /* ESTILOS INTERNOS DE LA HAMBURGUESA EN MÓVIL */
        .nav-services .btn-db-mobile { border-color: var(--primary); color: var(--primary); width: 100%; justify-content: center; }
        .nav-services .btn-db-mobile:hover { background: var(--primary); color: #fff; }
        .nav-services .btn-logout-mobile { border-color: var(--danger); color: var(--danger); width: 100%; justify-content: center; }
        .nav-services .btn-logout-mobile:hover { background: var(--danger); color: #fff; }

        /* SECCIONES ORIGINALES */
        .hero { padding: 80px 20px; text-align: center; background: linear-gradient(135deg, rgba(17,17,22,0.95) 0%, rgba(37,37,48,0.95) 100%); border-bottom: 1px solid #3f3f52; }
        .hero h2 { font-size: 2.8rem; margin-bottom: 15px; color: #fff; }
        .hero p { font-size: 1.1rem; color: var(--text-muted); max-width: 800px; margin: 0 auto; }
        .container { max-width: 1250px; margin: 50px auto; padding: 0 20px; }
        .section-title { font-size: 26px; margin-bottom: 10px; color: var(--primary); border-left: 4px solid var(--primary); padding-left: 15px; display: flex; align-items: center; gap: 10px;}
        .section-subtitle { color: var(--text-muted); margin-bottom: 30px; font-size: 1.05rem; }
        .grid-features { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 25px; margin-bottom: 60px; }
        .feature-card { background-color: var(--bg-card); border-radius: 8px; padding: 25px; border: 1px solid #3f3f52; transition: 0.3s ease; }
        .feature-card:hover { transform: translateY(-5px); border-color: var(--primary); background-color: var(--bg-card-hover); box-shadow: 0 10px 20px rgba(0,0,0,0.4); }
        .feature-card h3 { color: #fff; margin-bottom: 12px; font-size: 18px; border-bottom: 1px solid #3f3f52; padding-bottom: 10px;}
        .feature-card p { color: var(--text-muted); font-size: 14px; margin-bottom: 15px; }
        .feature-tag { display: inline-block; background: rgba(0, 173, 181, 0.15); color: var(--primary); padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; margin-right: 5px; margin-bottom: 5px;}
        footer { background-color: var(--bg-header); text-align: center; padding: 30px 20px; color: #666; font-size: 14px; border-top: 1px solid #3f3f52; margin-top: 50px; }

        /* RESPONSIVE RESPIRABLE (MÓVILES Y PANTALLAS COMPACTAS) */
        @media (max-width: 1150px) {
            header { padding: 15px 20px; }
            .menu-toggle { display: block; }

            .desktop-only { display: none !important; }
            .mobile-only { display: flex !important; }

            /* OPTIMIZACIÓN CRÍTICA PARA EL BOTÓN DE LOGUEO EN MÓVILES */
            .nav-auth { gap: 8px; }
            .user-logged { padding: 5px 10px; font-size: 13px; gap: 6px; }
            .user-logged .user-icon { display: none; } /* Ocultamos el emoji de PC para ganar espacio */
            .user-role { font-size: 10px; padding: 2px 6px; }
            .btn-login { padding: 6px 12px; font-size: 13px; }

            #menu-servicios {
                position: absolute;
                top: 100%;
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
        }
    </style>
</head>
<body>

    <header>
        <a href="https://innovatetech-g3.ddns.net/" class="logo" style="text-decoration: none;">
            <h1>Innovate<span>Tech</span></h1>
        </a>

        <nav id="menu-servicios">
            <ul class="nav-services">
                <li><a href="http://innovatech-g3.ddns.net/audio.php?session_id=<?php echo session_id(); ?>">📻 Streaming Audio</a></li>
                <li><a href="http://innovatech-g3.ddns.net/video.php?session_id=<?php echo session_id(); ?>">📺 Contenido Video</a></li>
                <li><a href="http://32.199.24.67/videollamada.php?session_id=<?php echo session_id(); ?>">🌐 Videollamada Jitsi</a></li>

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
                    <a href="https://innovatetech-g3.ddns.net/dashboard.php" class="btn-db desktop-only">Panel BD</a>
                <?php endif; ?>

                <a href="https://innovatetech-g3.ddns.net/logout.php" class="btn-logout desktop-only">Cerrar Sesión</a>
            <?php else: ?>
                <a href="login.php" class="btn-login">🔒 Iniciar Sesión</a>
            <?php endif; ?>

            <button class="menu-toggle" id="hamburguesa-btn" aria-label="Abrir menú">☰</button>
        </div>
    </header>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
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
    </script>
</body>
</html>