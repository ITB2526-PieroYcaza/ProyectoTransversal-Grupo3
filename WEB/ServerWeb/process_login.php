<?php
// 1. FORZAMOS LA CONFIGURACIÓN DE REDIS (Usamos 127.0.0.1 porque este archivo está en la misma máquina que Redis)
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://127.0.0.1:6379');

// OBLIGATORIO: Configuramos las cookies para que sean compartidas al saltar entre servidores
session_set_cookie_params([
    'path' => '/',
    'samesite' => 'Lax'
]);

session_start();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header("Location: login.php");
    exit();
}

// Limpiamos la entrada
$username = trim($_POST['username']);
$password = trim($_POST['password']);

// CONFIGURACIÓN ENTORNO LDAP
$ldap_host = "172.31.21.7";
$ldap_port = 389;
$base_dn = "dc=innovate,dc=tech,dc=itb,dc=cat";
$users_ou = "ou=usuarios," . $base_dn;
$groups_ou = "ou=grupos," . $base_dn;

$ldap_conn = @ldap_connect($ldap_host, $ldap_port);
if (!$ldap_conn) {
    header("Location: login.php?error=2");
    exit();
}

ldap_set_option($ldap_conn, LDAP_OPT_PROTOCOL_VERSION, 3);
ldap_set_option($ldap_conn, LDAP_OPT_REFERRALS, 0);

// BÚSQUEDA FLEXIBLE: Busca tanto por CN como por UID e incluimos "gidNumber" en la extracción
$user_filter = "(|(cn=" . $username . ")(uid=" . $username . "))";
$user_search = @ldap_search($ldap_conn, $users_ou, $user_filter, array("dn", "cn", "gidnumber", "uid"));

if (!$user_search) {
    header("Location: login.php?error=1");
    exit();
}

$user_entries = ldap_get_entries($ldap_conn, $user_search);

if ($user_entries['count'] == 0) {
    header("Location: login.php?error=1");
    exit();
}

$user_dn = $user_entries[0]['dn'];
$ldap_real_name = $user_entries[0]['cn'][0];
$ldap_uid = $user_entries[0]['uid'][0] ?? $username;
// Guardamos el GID primario que tiene el usuario en su propia ficha
$user_primary_gid = $user_entries[0]['gidnumber'][0] ?? null;

// Autenticación definitiva (Bind contra OpenLDAP)
$ldap_bind = @ldap_bind($ldap_conn, $user_dn, $password);

if (!$ldap_bind) {
    header("Location: login.php?error=1");
    exit();
}

// EXTRAER GRUPO SECUNDARIO PARA ROLES
$group_filter = "(&(objectClass=posixGroup)(memberUid=" . $ldap_uid . "))";
$group_search = @ldap_search($ldap_conn, $groups_ou, $group_filter, array("gidNumber"));

$detected_gid = null;

if ($group_search) {
    $entries = ldap_get_entries($ldap_conn, $group_search);

    if ($entries['count'] == 0) {
        // Reintento usando el nombre completo por si se guardó mal en elmemberUid
        $group_filter_retry = "(&(objectClass=posixGroup)(memberUid=" . $ldap_real_name . "))";
        $group_search_retry = @ldap_search($ldap_conn, $groups_ou, $group_filter_retry, array("gidNumber"));
        if ($group_search_retry) {
            $entries = ldap_get_entries($ldap_conn, $group_search_retry);
        }
    }

    if ($entries['count'] > 0) {
        $detected_gid = $entries[0]['gidnumber'][0];
    }
}

// ESTRATEGIA DE RESPALDO: Si no se detectó un grupo secundario, usamos el GID primario del usuario
if (empty($detected_gid) && !empty($user_primary_gid)) {
    $detected_gid = $user_primary_gid;
}

ldap_close($ldap_conn);

// MAPEADO DE ROLES EN BBDD
$mysql_user = "";
$mysql_pass = "pro-asixc1d-g3";

switch (intval($detected_gid)) {
    case 3001:
        $mysql_user = "admin";
        break;
    case 3002:
        $mysql_user = "vendes";
        break;
    case 3003:
        $mysql_user = "administracio";
        break;
    case 3004:
        $mysql_user = "treballador";
        break;
    case 3005:
        $mysql_user = "cliente";
        break;
    default:
        header("Location: login.php?error=3"); // El usuario no pertenece a un grupo del proyecto
        exit();
}

// GUARDAMOS TODO EN LA MEMORIA CENTRALIZADA DE REDIS
$_SESSION['usuari_ldap'] = $ldap_real_name;
$_SESSION['mysql_user'] = $mysql_user;
$_SESSION['mysql_pass'] = $mysql_pass;
$_SESSION['gid_rol'] = $detected_gid;

// Redirigimos al Home
header("Location: index.php");
exit();
?>