<?php
// Innovate Tech - Projecte Transversal ASIXc1
// auth.php — Autenticació LDAP i gestió de sessió

require_once 'config.php';

/**
 * Intenta autenticar un usuari contra el servidor OpenLDAP.
 * Si l'autenticació és correcta, desa el rol de l'usuari a la sessió
 * consultant l'atribut 'description' de l'entrada LDAP (on guardem el rol).
 */
function autenticarLDAP(string $user, string $password): bool {
    $ldap_conn = ldap_connect(LDAP_HOST, LDAP_PORT);
    if (!$ldap_conn) return false;

    ldap_set_option($ldap_conn, LDAP_OPT_PROTOCOL_VERSION, 3);
    ldap_set_option($ldap_conn, LDAP_OPT_REFERRALS, 0);

    $user_dn = "uid={$user},ou=" . LDAP_USERS_OU . "," . LDAP_BASE_DN;

    // Intentem el bind (login) amb les credencials de l'usuari
    $bind = @ldap_bind($ldap_conn, $user_dn, $password);

    if ($bind) {
        // Cerquem l'entrada LDAP per obtenir el rol (atribut 'description')
        $search = @ldap_search($ldap_conn, LDAP_BASE_DN,
            "(uid={$user})", ['cn', 'mail', 'description']);

        $rol = 'treballador'; // rol per defecte
        $nom = $user;
        $email = '';

        if ($search) {
            $entries = ldap_get_entries($ldap_conn, $search);
            if ($entries['count'] > 0) {
                $nom   = $entries[0]['cn'][0]          ?? $user;
                $email = $entries[0]['mail'][0]         ?? '';
                $rol   = $entries[0]['description'][0] ?? 'treballador';
                // Validem que el rol existeixi
                if (!in_array($rol, ROLS)) $rol = 'treballador';
            }
        }

        // Desa les dades de sessió
        $_SESSION['usuario'] = $user;
        $_SESSION['nom']     = $nom;
        $_SESSION['email']   = $email;
        $_SESSION['rol']     = $rol;

        ldap_close($ldap_conn);
        return true;
    }

    ldap_close($ldap_conn);
    return false;
}

/**
 * Middleware: redirigeix a login.php si no hi ha sessió activa.
 * S'ha de cridar a l'inici de cada pàgina protegida.
 */
function verificarSesion(): void {
    if (!isset($_SESSION['usuario'])) {
        header("Location: login.php");
        exit();
    }
}

/**
 * Comprova si l'usuari actual té un dels rols indicats.
 * Útil per mostrar o amagar seccions segons permisos.
 */
function teRol(string ...$rols): bool {
    return isset($_SESSION['rol']) && in_array($_SESSION['rol'], $rols);
}