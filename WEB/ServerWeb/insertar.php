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
if (!$tabla_activa) {
    die("Error: No s'ha especificat cap taula.");
}

$db_host = "172.31.30.119";
$db_pass = $_SESSION['mysql_pass'];
$db_name = "innovate_tech_db";

mysqli_report(MYSQLI_REPORT_OFF);
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    die("Error de connexió: " . $conn->connect_error);
}

// 1. OBTENER METADATOS DE LAS COLUMNAS DINÁMICAMENTE
$columnas = [];
$res_cols = $conn->query("SHOW COLUMNS FROM `$tabla_activa`");
if (!$res_cols) {
    die("Error al carregar l'estructura de la taula.");
}

while ($col = $res_cols->fetch_assoc()) {
    // Saltamos campos autoincrementales como IDs automáticos
    if (strpos($col['Extra'], 'auto_increment') !== false) {
        continue;
    }
    $columnas[] = [
        'campo' => $col['Field'],
        'tipo'  => $col['Type'],
        'nulo'  => $col['Null']
    ];
}

// 2. PROCESAR EL FORMULARIO (INSERT)
$error_msg = null;
$success_msg = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $campos_insert = [];
    $valores_insert = [];
    $tipos_bind = "";
    $valores_bind = [];

    foreach ($columnas as $col) {
        $campo = $col['campo'];
        if (isset($_POST[$campo])) {
            $campos_insert[] = "`$campo`";
            $valores_insert[] = "?";

            // Mapeo básico de tipos para el bind_param
            if (strpos($col['tipo'], 'int') !== false) {
                $tipos_bind .= "i";
            } elseif (strpos($col['tipo'], 'decimal') !== false || strpos($col['tipo'], 'float') !== false) {
                $tipos_bind .= "d";
            } else {
                $tipos_bind .= "s";
            }
            $valores_bind[] = $_POST[$campo];
        }
    }

    if (!empty($campos_insert)) {
        $sql = "INSERT INTO `$tabla_activa` (" . implode(', ', $campos_insert) . ") VALUES (" . implode(', ', $valores_insert) . ")";
        $stmt = $conn->prepare($sql);

        if ($stmt) {
            $stmt->bind_param($tipos_bind, ...$valores_bind);
            if ($stmt->execute()) {
                header("Location: dashboard.php?tabla=" . urlencode($tabla_activa));
                exit();
            } else {
                // Captura el SIGNAL 45000 del TRIGGER de seguridad
                $error_msg = "Error operatiu: " . $stmt->error;
            }
            $stmt->close();
        } else {
            $error_msg = "Error en la preparació de la consulta: " . $conn->error;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <title>InnovateTech - Inserir Registre</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #1e1e24; color: #f5f5f5; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .form-container { background-color: #111116; border: 2px solid #00adb5; border-radius: 8px; width: 100%; max-width: 600px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }
        h2 { color: #00adb5; margin-bottom: 5px; font-size: 22px; }
        .subtitle { color: #666; font-size: 13px; text-transform: uppercase; margin-bottom: 25px; letter-spacing: 0.5px; }
        .error-box { background-color: rgba(255, 46, 99, 0.15); border: 1px solid #ff2e63; color: #ff2e63; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-size: 14px; font-weight: 600; }
        .form-group { margin-bottom: 20px; display: flex; flex-direction: column; gap: 8px; }
        label { font-size: 12px; color: #00adb5; font-weight: bold; text-transform: uppercase; }
        input { background-color: #2a2a35; border: 1px solid #3f3f52; color: #fff; padding: 12px; border-radius: 5px; font-size: 14px; transition: 0.2s; width: 100%; }
        input:focus { border-color: #00adb5; outline: none; background-color: #31313d; }
        .btn-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn-submit { background-color: #00adb5; color: #fff; border: none; padding: 12px 20px; font-weight: bold; border-radius: 5px; cursor: pointer; transition: 0.3s; flex-grow: 1; text-transform: uppercase; font-size: 13px; }
        .btn-submit:hover { background-color: #008c9e; }
        .btn-cancel { background-color: #393e46; color: #fff; text-decoration: none; padding: 12px 20px; font-weight: bold; border-radius: 5px; text-align: center; transition: 0.3s; font-size: 13px; text-transform: uppercase; }
        .btn-cancel:hover { background-color: #4f5661; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>＋ Inserir Nou Registre</h2>
    <div class="subtitle">Taula activa: <?php echo htmlspecialchars($tabla_activa); ?></div>

    <?php if ($error_msg): ?>
        <div class="error-box">⚠️ <?php echo htmlspecialchars($error_msg); ?></div>
    <?php endif; ?>

    <form method="POST">
        <?php foreach ($columnas as $col): ?>
            <div class="form-group">
                <label for="<?php echo htmlspecialchars($col['campo']); ?>">
                    <?php echo htmlspecialchars($col['campo']); ?>
                    <span style="color:#666; font-size:11px; font-weight:normal;">(<?php echo htmlspecialchars($col['tipo']); ?>)</span>
                </label>
                <input type="text" name="<?php echo htmlspecialchars($col['campo']); ?>" id="<?php echo htmlspecialchars($col['campo']); ?>" required>
            </div>
        <?php endforeach; ?>

        <div class="btn-group">
            <a href="dashboard.php?tabla=<?php echo urlencode($tabla_activa); ?>" class="btn-cancel">Cancel·lar</a>
            <button type="submit" class="btn-submit">Guardar Registre</button>
        </div>
    </form>
</div>

</body>
</html>
<?php $conn->close(); ?>