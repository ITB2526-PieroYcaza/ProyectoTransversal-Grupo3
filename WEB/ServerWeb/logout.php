<?php
// OBLIGATORIO: Conectar con el almacenamiento centralizado en Redis antes de destruir la sesión
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://127.0.0.1:6379');
session_start();

// Vaciamos y destruimos la sesión en la memoria RAM de Redis
session_unset();
session_destroy();

// Redirigimos al usuario a la portada pública del portal principal
header("Location: index.php");
exit();