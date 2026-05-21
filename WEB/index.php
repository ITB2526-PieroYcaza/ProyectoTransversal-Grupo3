<?php
session_start();
if (empty($_SESSION['autenticado'])) {
    header('Location: login.php');
    exit;
}
?>

<!DOCTYPE html>
<html>
<head><title>Index</title></head>
<body>
    <h2>Bienvenido, <?= htmlspecialchars($_SESSION['usuario']) ?></h2>
    <a href="logout.php">Cerrar sesión</a>
</body>
</html>