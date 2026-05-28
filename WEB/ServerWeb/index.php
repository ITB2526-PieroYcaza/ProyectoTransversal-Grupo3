<?php
// Incluimos toda la cabecera, estilos e inicio de sesión con Redis
include("header.php");
?>

<div class="dashboard-theme">
    <style>
        .dashboard-theme {
            --primary: #00adb5;
            --primary-hover: #008c9e;
            --bg-dark: #1a1a20;
            --bg-header: #111116;
            --bg-card: #252530;
            --text-light: #f5f5f5;
            --text-muted: #a0a0b0;
            --danger: #ff2e63;
            --success: #00e676;
            --warning: #ffb703;
            --border-color: #3f3f52;

            background-color: var(--bg-dark);
            color: var(--text-light);
            font-family: 'Inter', 'Segoe UI', sans-serif;
            line-height: 1.6;
        }

        /* HERO SECTION */
        .dashboard-theme .hero {
            padding: 50px 40px;
            background: linear-gradient(135deg, var(--bg-header) 0%, #222831 100%);
            border-bottom: 2px solid var(--primary);
            text-align: center;
        }
        .dashboard-theme .hero h2 { font-size: 32px; color: #fff; margin-bottom: 12px; font-weight: 700; }
        .dashboard-theme .hero p { font-size: 16px; color: var(--text-muted); max-width: 800px; margin: 0 auto; }

        .dashboard-theme .container { max-width: 1400px; margin: 40px auto; padding: 0 40px; }

        .dashboard-theme .section-title { font-size: 22px; margin: 40px 0 10px 0; color: var(--primary); border-left: 4px solid var(--primary); padding-left: 15px; font-weight: 600; }
        .dashboard-theme .section-title:first-of-type { margin-top: 0; }
        .dashboard-theme .section-subtitle { color: var(--text-muted); margin-bottom: 25px; font-size: 14px; }

        /* GRID DE TARJETAS DE SERVICIOS */
        .dashboard-theme .grid-features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 25px; }
        .dashboard-theme .feature-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 30px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .dashboard-theme .feature-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.3); border-color: var(--primary); }
        .dashboard-theme .feature-card h3 { font-size: 18px; color: #fff; margin-bottom: 12px; display: flex; align-items: center; gap: 10px; }
        .dashboard-theme .feature-card p { font-size: 14px; color: var(--text-muted); margin-bottom: 20px; flex-grow: 1; }

        .dashboard-theme .feature-tags { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 15px; }
        .dashboard-theme .feature-tag { background: rgba(255,255,255,0.05); border: 1px solid var(--border-color); color: var(--text-light); font-size: 11px; padding: 4px 10px; border-radius: 4px; font-weight: 500; }

        .dashboard-theme .btn-action { display: inline-flex; align-items: center; justify-content: center; gap: 8px; background: var(--primary); color: #fff; text-decoration: none; font-size: 13px; font-weight: 600; padding: 10px; border-radius: 6px; transition: 0.2s; width: 100%; text-transform: uppercase; }
        .dashboard-theme .btn-action:hover { background: var(--primary-hover); }

        /* MONITORIZACIÓN DE RED */
        .dashboard-theme .network-dashboard { background: var(--bg-header); border: 1px solid var(--border-color); border-radius: 10px; padding: 30px; }
        .dashboard-theme .network-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin: 25px 0; }
        .dashboard-theme .stat-box { background: var(--bg-card); border: 1px solid var(--border-color); border-radius: 8px; padding: 20px; text-align: center; }
        .dashboard-theme .stat-box h4 { font-size: 13px; color: var(--text-muted); text-transform: uppercase; margin-bottom: 8px; font-weight: 600; }
        .dashboard-theme .stat-value { font-size: 28px; font-weight: 700; }
        .dashboard-theme .stat-value.success { color: var(--success); }
        .dashboard-theme .stat-value.warning { color: var(--warning); }

        .dashboard-theme .status-badge { background: rgba(0, 230, 118, 0.1); border: 1px solid var(--success); color: var(--success); padding: 6px 16px; border-radius: 4px; font-size: 12px; font-weight: 700; display: inline-block; }

        /* SECCIÓN SGBD / BASE DE DATOS */
        .dashboard-theme .db-section { display: grid; grid-template-columns: repeat(auto-fit, minmax(450px, 1fr)); gap: 25px; }
        .dashboard-theme .db-card { background: var(--bg-header); border: 1px solid var(--border-color); border-top: 4px solid var(--primary); border-radius: 8px; padding: 25px; }
        .dashboard-theme .db-card h4 { font-size: 16px; color: #fff; margin-bottom: 20px; font-weight: 600; }
        .dashboard-theme .db-list { list-style: none; }
        .dashboard-theme .db-list li { font-size: 13px; color: var(--text-muted); padding: 10px 0; border-bottom: 1px dashed var(--border-color); line-height: 1.5; }
        .dashboard-theme .db-list li:last-child { border-bottom: none; }
        .dashboard-theme .db-list li strong { color: #fff; display: inline-block; min-width: 120px; }

        /* SUSTENTABILIDAD GREEN IT */
        .dashboard-theme .green-it-box { background: linear-gradient(90deg, rgba(0, 230, 118, 0.03) 0%, rgba(0, 173, 181, 0.03) 100%); border: 1px solid var(--border-color); border-left: 4px solid var(--success); padding: 25px; border-radius: 8px; margin-top: 20px; }

        /* FOOTER ALTERNATIVO INTEGRADO */
        .dashboard-theme footer { background-color: var(--bg-header); text-align: center; padding: 30px; color: #666; font-size: 13px; border-top: 1px solid #2a2a35; margin-top: 60px; line-height: 1.8; }

        @media (max-width: 950px) {
            .dashboard-theme .container { padding: 0 20px; }
            .dashboard-theme .db-section { grid-template-columns: 1fr; }
        }
    </style>

    <section class="hero">
        <h2>Portal Operativo de Sistemas y Servicios</h2>
        <p>Infraestructura distribuida en entornos elásticos AWS. Minimizamos la latencia y maximizamos la seguridad lógica mediante despliegues centralizados con Ansible y redundancia de datos.</p>
    </section>

    <div class="container">

        <h3 class="section-title">🏢 Arquitectura del Centro de Procesamiento de Datos</h3>
        <p class="section-subtitle">Acceso directo e indicadores técnicos de los microservicios aprovisionados en el clúster.</p>

        <div class="grid-features">
            <div class="feature-card">
                <div>
                    <h3>🔒 Identidad (LDAP) y SFTP</h3>
                    <p>Aislamiento perimetral en la DMZ para intercambio seguro de ficheros. Autenticación unificada de cuentas sin privilegios interactivos de terminal corporativo.</p>
                </div>
                <div>
                    <div class="feature-tags">
                        <span class="feature-tag">OpenLDAP</span>
                        <span class="feature-tag">Puerto 22</span>
                        <span class="feature-tag">Chroot</span>
                    </div>
                    <a href="http://18.235.254.161/lam" target="_blank" class="btn-action">Gestionar Directorio</a>
                </div>
            </div>

            <div class="feature-card">
                <div>
                    <h3>📻 Streaming de Audio</h3>
                    <p>Punto de montaje Icecast dedicado para la distribución multimedia continua interna a una tasa de transferencia fija de 128 kbps.</p>
                </div>
                <div>
                    <div class="feature-tags">
                        <span class="feature-tag">Icecast 2</span>
                        <span class="feature-tag">Puerto 8000</span>
                        <span class="feature-tag">MP3/OGG</span>
                    </div>
                    <a href="http://35.169.183.22/audio.php?session_id=<?php echo session_id(); ?>" class="btn-action">Abrir Sintonizador</a>
                </div>
            </div>

            <div class="feature-card">
                <div>
                    <h3>📺 WebRTC y Conferencia</h3>
                    <p>Salas interconectadas de comunicación por video en tiempo real. Tráfico seguro procesado sobre contenedores aislados y códecs de alto rendimiento.</p>
                </div>
                <div>
                    <div class="feature-tags">
                        <span class="feature-tag">Jitsi Meet</span>
                        <span class="feature-tag">Puerto 8443</span>
                        <span class="feature-tag">SRTP / WebRTC</span>
                    </div>
                    <a href="http://32.199.24.67/videollamada.php?session_id=<?php echo session_id(); ?>" class="btn-action">Iniciar Videollamada</a>
                </div>
            </div>

            <div class="feature-card">
                <div>
                    <h3>🤖 Orquestación y Logs</h3>
                    <p>Aprovisionamiento técnico de instancias mediante Playbooks estructurados de Ansible y analítica unificada mediante pila centralizada SIEM.</p>
                </div>
                <div>
                    <div class="feature-tags">
                        <span class="feature-tag">Ansible Core</span>
                        <span class="feature-tag">Elasticsearch</span>
                        <span class="feature-tag">Kibana 5601</span>
                    </div>
                    <a href="http://34.226.127.76:5601/" target="_blank" class="btn-action">Visor de Auditoría</a>
                </div>
            </div>
        </div>

        <h3 class="section-title">📊 Monitorización y Rendimiento de Red</h3>
        <p class="section-subtitle">Métricas del balanceador y capacidades de ancho de banda del CPD central.</p>

        <div class="network-dashboard">
            <p style="color: var(--text-muted); font-size: 14px;">Evaluación continua del tráfico de red para soportar la concurrencia simultánea de flujos multimedia de alta demanda sin pérdidas de paquetes TCP/UDP.</p>
            <div class="network-stats">
                <div class="stat-box">
                    <h4>Velocidad de Bajada</h4>
                    <div class="stat-value success">945 Mbps</div>
                </div>
                <div class="stat-box">
                    <h4>Velocidad de Subida</h4>
                    <div class="stat-value success">850 Mbps</div>
                </div>
                <div class="stat-box">
                    <h4>Latencia Base (RTT)</h4>
                    <div class="stat-value warning">12 ms</div>
                </div>
            </div>
            <div style="text-align: right;">
                <span class="status-badge">✔ ESTADO DEL SISTEMA: OPTIMIZADO</span>
            </div>
        </div>

        <h3 class="section-title">💾 Base de Datos Relacional y Políticas de Acceso</h3>
        <p class="section-subtitle">Políticas del Sistema de Gestión de Bases de Datos (SGBD) asociadas a roles.</p>

        <div class="db-section">
            <div class="db-card">
                <h4>🛡️ Roles y Privilegios Corporativos (DCL)</h4>
                <ul class="db-list">
                    <li><strong>Admin:</strong> Privilegios totales de control estructurado (DDL/DML). Mantenimiento técnico global.</li>
                    <li><strong>Ventas:</strong> Acceso a registros comerciales e historial básico de salas multimedia.</li>
                    <li><strong>Administración:</strong> Permisos específicos sobre la gestión de personal (Nóminas y RRHH).</li>
                </ul>
            </div>
            <div class="db-card">
                <h4>⚡ Reglas de Automatización de Auditoría (Triggers)</h4>
                <ul class="db-list">
                    <li><strong>Control de Cuotas:</strong> Almacena y limita el cómputo de llamadas consumidas por cuenta.</li>
                    <li><strong>Tabla de Avisos (Logs):</strong> Captura inmediata e inserción de alertas ante modificaciones no autorizadas.</li>
                    <li><strong>Límites concurrentes:</strong> Restringe la sobresaturación de peticiones de escritura a la BD.</li>
                </ul>
            </div>
        </div>

        <h3 class="section-title">🌱 Transformación Digital y Sostenibilidad</h3>
        <p class="section-subtitle" style="margin-bottom: 0;">Infraestructura verde.</p>

        <div class="green-it-box">
            <p style="font-size: 14px; color: var(--text-muted); line-height: 1.6;">
                Nuestros servidores aplican políticas estrictas de <strong>Green IT</strong> para la optimización de recursos informáticos en la nube, minimizando la huella ecológica general. Los flujos de datos sensibles se procesan bajo entornos de aislamiento lógico, garantizando tanto el cumplimiento normativo de protección de datos como una alta eficiencia térmica y energética en el CPD.
            </p>
        </div>

    </div>

    <footer>
        © 2026 InnovateTech S.L. - Proyecto Transversal ASIXc1D - Grupo 3 <br>
        <span style="font-size: 12px; color: #666; margin-top: 10px; display: inline-block;">Cumplimiento de los RAs: 0371, 0375, 0377 y 1665 | Curso 2025/2026</span>
    </footer>
</div>

</body>
</html>