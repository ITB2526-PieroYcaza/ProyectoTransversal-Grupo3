<?php
// Forzamos a PHP a usar Redis apuntando a tu servidor principal antes de arrancar la sesión
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://127.0.0.1:6379');
session_start();

// Si ya está logueado, lo mandamos de vuelta al index
if (isset($_SESSION['usuari_ldap'])) {
    header("Location: index.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InnovateTech - Iniciar Sessió</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #1e1e24; color: #f5f5f5; display: flex; justify-content: center; align-items: center; min-height: 100vh; }

        .login-container { background-color: #111116; border-radius: 8px; padding: 40px; width: 100%; max-width: 400px; border: 1px solid #3f3f52; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }
        .login-container h2 { text-align: center; color: #00adb5; margin-bottom: 10px; font-size: 26px; }
        .login-container p { text-align: center; color: #a0a0b0; font-size: 14px; margin-bottom: 30px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #b5b5c3; font-size: 14px; font-weight: 600; }
        .form-group input { width: 100%; padding: 12px; background-color: #2a2a35; border: 1px solid #3f3f52; border-radius: 5px; color: #fff; font-size: 15px; transition: 0.3s; }
        .form-group input:focus { border-color: #00adb5; outline: none; background-color: #31313d; }

        .btn-submit { width: 100%; padding: 12px; background-color: #00adb5; border: none; border-radius: 5px; color: #fff; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        .btn-submit:hover { background-color: #008c9e; }

        .error-box { background-color: rgba(255, 46, 99, 0.2); border: 1px solid #ff2e63; color: #ff2e63; padding: 12px; border-radius: 5px; font-size: 14px; margin-bottom: 20px; text-align: center; }
        .back-link { display: block; text-align: center; margin-top: 20px; color: #666; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: #00adb5; text-decoration: underline; }
    </style>
</head>
<body>

    <div class="login-container">
        <h2>InnovateTech</h2>
        <p>Autenticació centralitzada OpenLDAP</p>

        <?php if (isset($_GET['error'])): ?>
            <div class="error-box">
                <?php
                    if($_GET['error'] == 1) echo "Usuari o contrasenya LDAP incorrectes.";
                    elseif($_GET['error'] == 2) echo "No s'ha pogut connectar amb el servidor LDAP.";
                    else echo "Error en l'autenticació.";
                ?>
            </div>
        <?php endif; ?>

        <form action="process_login.php" method="POST">
            <div class="form-group">
                <label for="username">Usuari LDAP (UID)</label>
                <input type="text" id="username" name="username" placeholder="Ex: marta_vendes" required>
            </div>

            <div class="form-group">
                <label for="password">Contrasenya</label>
                <input type="password" id="password" name="password" placeholder="••••••••" required>
            </div>

            <button type="submit" class="btn-submit">Validar Credencials</button>
        </form>

        <a href="index.php" class="back-link">← Tornar a la portada pública</a>
    </div>

</body>
</html>