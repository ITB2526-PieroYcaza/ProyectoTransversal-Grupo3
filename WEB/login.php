<?php
session_start();
if (!empty($_SESSION['autenticado'])) {
    header('Location: dashboard.php');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $usuario  = trim($_POST['usuario']);
    $password = $_POST['password'];

    $host    = 'ldap://tu-servidor-ldap';   // ← IP o hostname servidor LDAP
    $base_dn = 'dc=empresa,dc=com';         // ← DN
    $bind_dn = "uid={$usuario},{$base_dn}";  // Cambiar

    $conn = ldap_connect($host);
    ldap_set_option($conn, LDAP_OPT_PROTOCOL_VERSION, 3);
    ldap_set_option($conn, LDAP_OPT_REFERRALS, 0);

    if (@ldap_bind($conn, $bind_dn, $password)) {
        $_SESSION['autenticado'] = true;
        $_SESSION['usuario']     = $usuario;
        header('Location: dashboard.php');
        exit;
    } else {
        $error = 'Usuario o contraseña incorrectos';
    }
    ldap_unbind($conn);
}
?>

<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
    <h2>Iniciar sesión</h2>
    <?php if ($error): ?>
        <p style="color:red"><?= $error ?></p>
    <?php endif; ?>
    <form method="POST">
        <input type="text"     name="usuario"  placeholder="Usuario"    required><br><br>
        <input type="password" name="password" placeholder="Contraseña" required><br><br>
        <button type="submit">Entrar</button>
    </form>
</body>
</html>