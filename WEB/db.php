<?php
// Innovate Tech - Projecte Transversal ASIXc1
// db.php — Connexió a la base de dades MySQL via PDO

require_once 'config.php';

try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );
} catch (PDOException $e) {
    // En producció mai mostris el missatge complet; aquí el mostrem per a depurar
    die(json_encode([
        'error' => 'Error de connexió a la base de dades',
        'detall' => $e->getMessage()
    ]));
}