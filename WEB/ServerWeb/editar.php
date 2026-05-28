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

// 1. DETECTAR LA CLAVE PRIMARIA Y CAMPOS DE LA TAULA
$pk_campo = null;
$columnas = [];
$res_cols = $conn->query("SHOW COLUMNS FROM `$tabla_activa`");

while ($col = $res_cols->fetch_assoc()) {
    if ($col['Key'] === 'PRI') {
        $pk_campo = $col['Field'];
    }
    $columnas[] = $col['Field'];
}

if (!$pk_campo) {
    die("Error: Aquesta interfície dinàmica requereix que la taula tingui una Clau Primària (PRI).");
}

$id_registro = isset($_GET['id']) ? $_GET['id'] : null;
if (!$id_registro) {
    die("Error: No s'ha definit el ID del registre a editar.");
}

// 2. RECUPERAR LOS DATOS ACTUALES DEL REGISTRO
$stmt_get = $conn->prepare("SELECT * FROM `$tabla_activa` WHERE `$pk_campo` = ?");
$stmt_get->bind_param("s", $id_registro);
$stmt_get->execute();
$res_reg = $stmt_get->get_result();
$registro = $res_reg->fetch_assoc();
$stmt_get->close();

if (!$registro) {
    die("Registre no trobat.");
}

// 3. PROCESAR LA ACTUALIZACIÓN (UPDATE)
$error_msg = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sets = [];
    $tipos_bind = "";
    $valores_bind = [];

    foreach ($columnas as $campo) {
        if ($campo === $pk_campo) continue; // No editamos el ID clave
        if (isset($_POST[$campo])) {
            $sets[] = "`$campo` = ?";
            $tipos_bind .= "s"; // Bind genérico como string para inputs sanitizados
            $valores_bind[] = $_POST[$campo];
        }
    }

    if (!empty($sets)) {
        $sql = "UPDATE `$tabla_activa` SET " . implode(', ', $sets) . " WHERE `$pk_campo` = ?";
        $tipos_bind .= "s";
        $valores_bind[] = $id_registro;

        $stmt_up = $conn->prepare($sql);
        if ($stmt_up) {
            $stmt_up->bind_param($tipos_bind, ...$valores_bind);
            if ($stmt_up->execute()) {
                header("Location: dashboard.php?tabla=" . urlencode($tabla_activa));
                exit();
            } else {
                $error_msg = "Error operatiu: " . $stmt_up->error;
            }
            $stmt_up->close();
        } else {
            $error_msg = "Error a la consulta: " . $conn->error;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <title>InnovateTech - Editar Registre</title>
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
        input:disabled { background-color: #17171f; color: #666; border-color: #2a2a35; cursor: not-allowed; }
        .btn-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn-submit { background-color: #00adb5; color: #fff; border: none; padding: 12px 20px; font-weight: bold; border-radius: 5px; cursor: pointer; transition: 0.3s; flex-grow: 1; text-transform: uppercase; font-size: 13px; }
        .btn-submit:hover { background-color: #008c9e; }
        .btn-cancel { background-color: #393e46; color: #fff; text-decoration: none; padding: 12px 20px; font-weight: bold; border-radius: 5px; text-align: center; transition: 0.3s; font-size: 13px; text-transform: uppercase; }
        .btn-cancel:hover { background-color: #4f5661; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>📝 Modificar Registre</h2>
    <div class="subtitle">Taula: <?php echo htmlspecialchars($tabla_activa); ?> | Clau ID: <?php echo htmlspecialchars($id_registro); ?></div>

    <?php if ($error_msg): ?>
        <div class="error-box">⚠️ <?php echo htmlspecialchars($error_msg); ?></div>
    <?php endif; ?>

    <form method="POST">
        <?php foreach ($columnas as $campo): ?>
            <div class="form-group">
                <label for="<?php echo htmlspecialchars($campo); ?>"><?php echo htmlspecialchars($campo); ?></label>
                <?php if ($campo === $pk_campo): ?>
                    <input type="text" id="<?php echo htmlspecialchars($campo); ?>" value="<?php echo htmlspecialchars($registro[$campo] ?? ''); ?>" disabled>
                <?php else: ?>
                    <input type="text" name="<?php echo htmlspecialchars($campo); ?>" id="<?php echo htmlspecialchars($campo); ?>" value="<?php echo htmlspecialchars($registro[$campo] ?? ''); ?>" required>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>

        <div class="btn-group">
            <a href="dashboard.php?tabla=<?php echo urlencode($tabla_activa); ?>" class="btn-cancel">Tornar</a>
            <button type="submit" class="btn-submit">Desar Canvis</button>
        </div>
    </form>
</div>

</body>
</html>
<?php $conn->close(); ?>