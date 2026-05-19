<?php
// Innovate Tech - Projecte Transversal ASIXc1
// login.php — Formulari d'accés amb autenticació LDAP

require_once 'auth.php';

// Si ja hi ha sessió activa, redirigim directament al panel
if (isset($_SESSION['usuario'])) {
    header("Location: index.php");
    exit();
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user = trim($_POST['user'] ?? '');
    $pass = $_POST['pass'] ?? '';

    if ($user === '' || $pass === '') {
        $error = 'Introdueix usuari i contrasenya.';
    } elseif (autenticarLDAP($user, $pass)) {
        header("Location: index.php");
        exit();
    } else {
        $error = 'Usuari o contrasenya LDAP incorrectes.';
    }
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Innovate Tech — Accés</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: #0A0F1E;
      color: #E8ECF4;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .login-wrap {
      width: 100%;
      max-width: 400px;
      padding: 24px;
    }

    .logo {
      display: flex;
      align-items: center;
      gap: 10px;
      justify-content: center;
      margin-bottom: 36px;
    }
    .logo-dot {
      width: 10px; height: 10px;
      border-radius: 50%;
      background: #3B82F6;
      animation: pulse 2s infinite;
    }
    @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.4} }
    .logo-text {
      font-family: 'Syne', sans-serif;
      font-size: 22px;
      color: #fff;
      letter-spacing: -0.5px;
    }

    .card {
      background: rgba(255,255,255,0.04);
      border: 0.5px solid rgba(255,255,255,0.1);
      border-radius: 16px;
      padding: 32px;
    }

    .card h2 {
      font-family: 'Syne', sans-serif;
      font-size: 20px;
      color: #fff;
      margin-bottom: 6px;
    }
    .card .sub {
      font-size: 13px;
      color: rgba(232,236,244,0.45);
      margin-bottom: 28px;
    }

    .field { margin-bottom: 16px; }
    .field label {
      display: block;
      font-size: 12px;
      color: rgba(232,236,244,0.5);
      margin-bottom: 6px;
    }
    .field input {
      width: 100%;
      background: rgba(255,255,255,0.05);
      border: 0.5px solid rgba(255,255,255,0.12);
      border-radius: 8px;
      padding: 11px 14px;
      font-size: 14px;
      color: #E8ECF4;
      font-family: 'DM Sans', sans-serif;
      transition: border-color 0.2s;
      outline: none;
    }
    .field input:focus { border-color: rgba(59,130,246,0.6); }
    .field input::placeholder { color: rgba(232,236,244,0.2); }

    .error {
      background: rgba(226,75,74,0.1);
      border: 0.5px solid rgba(226,75,74,0.3);
      border-radius: 8px;
      padding: 10px 14px;
      font-size: 13px;
      color: #FCA5A5;
      margin-bottom: 16px;
    }

    .btn-submit {
      width: 100%;
      background: #3B82F6;
      border: none;
      color: #fff;
      font-size: 15px;
      font-weight: 500;
      padding: 13px;
      border-radius: 10px;
      cursor: pointer;
      font-family: 'DM Sans', sans-serif;
      margin-top: 8px;
      transition: background 0.2s;
    }
    .btn-submit:hover { background: #2563EB; }

    .note {
      font-size: 12px;
      color: rgba(232,236,244,0.3);
      text-align: center;
      margin-top: 20px;
    }
    .note span { color: #3B82F6; }
  </style>
</head>
<body>
  <div class="login-wrap">
    <div class="logo">
      <span class="logo-dot"></span>
      <span class="logo-text">Innovate Tech</span>
    </div>

    <div class="card">
      <h2>Accés al portal</h2>
      <p class="sub">Introdueix les teves credencials corporatives</p>

      <?php if ($error): ?>
        <div class="error"><?= htmlspecialchars($error) ?></div>
      <?php endif; ?>

      <form method="POST" action="login.php">
        <div class="field">
          <label for="user">Usuari LDAP</label>
          <input type="text" id="user" name="user"
                 placeholder="usuari@innovatetech.lan"
                 value="<?= htmlspecialchars($_POST['user'] ?? '') ?>"
                 autocomplete="username" required>
        </div>
        <div class="field">
          <label for="pass">Contrasenya</label>
          <input type="password" id="pass" name="pass"
                 placeholder="••••••••"
                 autocomplete="current-password" required>
        </div>
        <button type="submit" class="btn-submit">Iniciar sessió</button>
      </form>

      <p class="note">Autenticació via <span>OpenLDAP</span> · Dades a <span>MySQL</span></p>
    </div>
  </div>
</body>
</html>