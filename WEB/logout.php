<?php
// Innovate Tech - Projecte Transversal ASIXc1
// logout.php — Tancament de sessió

session_start();

// Buidem totes les variables de sessió
$_SESSION = [];

// Esborrem la cookie de sessió del navegador
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(
        session_name(), '',
        time() - 42000,
        $params["path"],
        $params["domain"],
        $params["secure"],
        $params["httponly"]
    );
}

// Destruïm la sessió al servidor
session_destroy();

// Redirigim al login
header("Location: login.php");
exit();