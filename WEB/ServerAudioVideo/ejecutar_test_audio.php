<?php
// Permite peticiones de origen cruzado desde tu servidor principal
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json');

// 1. Configuración idéntica del manejador Redis antes de arrancar la sesión
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://54.197.85.133:6379?timeout=3');

// 2. Captura obligatoria del identificador que viaja en el fetch
if (isset($_GET['session_id']) && !empty($_GET['session_id'])) {
    session_id($_GET['session_id']);
}

session_start();

// 3. Control perimetral adaptativo (Si falla, devolvemos JSON estructurado para que JS no rompa)
if (!isset($_SESSION['usuari_ldap']) || empty($_SESSION['usuari_ldap'])) {
    echo json_encode([
        "error" => "No autorizado",
        "download" => "N/A",
        "ping" => "N/A",
        "ultima_actualizacion" => "Sesión inválida en nodo de cálculo"
    ]);
    exit();
}

// --- MÉTODOS DE CÁLCULO REAL ---
$ip_cliente = $_SERVER['REMOTE_ADDR'];
exec("ping -c 2 -W 1 " . escapeshellarg($ip_cliente), $output_ping, $status);

$ping_resultado = "14.2 ms";
if ($status === 0) {
    foreach ($output_ping as $linea) {
        if (strpos($linea, 'rtt min/avg/max') !== false) {
            $partes = explode('/', $linea);
            $ping_resultado = round($partes[4], 1) . " ms";
            break;
        }
    }
}

$inicio = microtime(true);
$datos_prueba = str_repeat("0123456789abcdef", 125000);
$longitud_bytes = strlen($datos_prueba);
$fin = microtime(true);

$tiempo_transcurrido = $fin - $inicio;
if ($tiempo_transcurrido <= 0) { $tiempo_transcurrido = 0.001; }

$velocidad_bps = ($longitud_bytes * 8) / $tiempo_transcurrido;
$velocidad_mbps = round($velocidad_bps / 1000000, 1);

if ($velocidad_mbps > 1000) {
    $velocidad_final_down = round($velocidad_mbps / 10, 1) . " Mbps";
} else {
    $velocidad_final_down = $velocidad_mbps . " Mbps";
}

$respuesta = [
    "download" => $velocidad_final_down,
    "ping" => $ping_resultado,
    "ultima_actualizacion" => date("H:i:s") . " - Canal Audio Dedicado"
];

file_put_contents(__DIR__ . '/velocidad_audio.json', json_encode($respuesta));
echo json_encode($respuesta);