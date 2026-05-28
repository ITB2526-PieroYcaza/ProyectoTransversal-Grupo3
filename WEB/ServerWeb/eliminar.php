<?php
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://54.197.85.133:6379?timeout=3');
session_start();

if (!isset($_SESSION['usuari_ldap']) || !isset($_SESSION['mysql_user'])) {
    header("Location: index.php");
    exit();
}

$db_user = $_SESSION['mysql_user'];
if ($db_user === 'treballador') {
    header("Location: dashboard.php");
    exit();
}

$tabla_activa = isset($_GET['tabla']) ? $_GET['tabla'] : null;
$id_registro = isset($_GET['id']) ? $_GET['id'] : null;

if (!$tabla_activa || !$id_registro) {
    die("Paràmetres insuficients per realitzar l'esborrat.");
}

$db_host = "172.31.30.119";
$db_pass = $_SESSION['mysql_pass'];
$db_name = "innovate_tech_db";

mysqli_report(MYSQLI_REPORT_OFF);
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    die("Error de connexió: " . $conn->connect_error);
}

// 1. CONOCER LA CAMPO CLAVE PRIMARIA
$pk_campo = null;
$res_cols = $conn->query("SHOW COLUMNS FROM `$tabla_activa`");
while ($col = $res_cols->fetch_assoc()) {
    if ($col['Key'] === 'PRI') {
        $pk_campo = $col['Field'];
        break;
    }
}

if (!$pk_campo) {
    die("Error: No es pot eliminar en una taula sense Clau Primària.");
}

// 2. PROCESAR ACCIÓN DE BORRADO DE FORMA DIRECTA O CON CONFIRMACIÓN
$error_operacion = null;

if (isset($_POST['confirmar_borrado'])) {
    $stmt_del = $conn->prepare("DELETE FROM `$tabla_activa` WHERE `$pk_campo` = ?");
    if ($stmt_del) {
        $stmt_del->bind_param("s", $id_registro);
        if ($stmt_del->execute()) {
            header("Location: dashboard.php?tabla=" . urlencode($tabla_activa));
            exit();
        } else {
            // Captura de mensaje del SIGNAL SQLSTATE 45000 de los Triggers
            $error_operacion = $stmt_del->error;
        }
        $stmt_del->close();
    } else {
        $error_operacion = $conn->error;
    }
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <title>InnovateTech - Confirmar Eliminació</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #1e1e24; color: #f5f5f5; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .delete-box { background-color: #111116; border: 2px solid #ff2e63; border-radius: 8px; width: 100%; max-width: 500px; padding: 30px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.6); }
        h2 { color: #ff2e63; margin-bottom: 15px; font-size: 22px; }
        p { color: #b5b5c3; font-size: 15px; margin-bottom: 25px; line-height: 1.5; }
        .danger-zone { background-color: rgba(255, 46, 99, 0.1); padding: 12px; border-radius: 5px; font-family: monospace; font-size: 13px; color: #f5f5f5; margin-bottom: 25px; border: 1px dashed #ff2e63; }
        .error-box { background-color: rgba(255, 46, 99, 0.2); border: 1px solid #ff2e63; color: #ff2e63; padding: 12px; border-radius: 5px; margin-bottom: 20px; font-size: 14px; text-align: left; font-weight: bold; }
        .btn-group { display: flex; gap: 15px; justify-content: center; }
        .btn-delete { background-color: #ff2e63; color: #fff; border: none; padding: 12px 25px; font-weight: bold; border-radius: 5px; cursor: pointer; transition: 0.3s; text-transform: uppercase; font-size: 13px; }
        .btn-delete:hover { background-color: #e01b4c; }
        .btn-cancel { background-color: #393e46; color: #fff; text-decoration: none; padding: 12px 25px; font-weight: bold; border-radius: 5px; transition: 0.3s; text-transform: uppercase; font-size: 13px; }
        .btn-cancel:hover { background-color: #4f5661; }
    </style>
</head>
<body>

<div class="delete-box">
    <h2>⚠️ Confirmar Eliminació</h2>
    <p>Estàs segur que vols suprimir de forma permanent aquest registre? Aquesta acció es registrarà immediatament al sistema de control d'auditories.</p>

    <div class="danger-zone">
        TAULA: <?php echo htmlspecialchars($tabla_activa); ?><br>
        REGISTRE IDENTIFICADOR (PRI): <?php echo htmlspecialchars($id_registro); ?>
    </div>

    <?php if ($error_operacion): ?>
        <div class="error-box">
            ❌ <strong>SGBD Restricció:</strong><br>
            <?php echo htmlspecialchars($error_operacion); ?>
        </div>
    <?php endif; ?>

    <form method="POST">
        <div class="btn-group">
            <a href="dashboard.php?tabla=<?php echo urlencode($tabla_activa); ?>" class="btn-cancel">Cancel·lar</a>
            <button type="submit" name="confirmar_borrado" class="btn-delete">Eliminar Registre</button>
        </div>
    </form>
</div>

</body>
</html>
<?php $conn->close(); ?>