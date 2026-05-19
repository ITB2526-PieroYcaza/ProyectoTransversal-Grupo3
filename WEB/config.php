<?php
// Innovate Tech - Projecte Transversal ASIXc1
// config.php — Configuració global

session_start();

// ── Configuració LDAP ──────────────────────────────────────────
define('LDAP_HOST',     'ldap://127.0.0.1');
define('LDAP_PORT',     389);
define('LDAP_BASE_DN',  'dc=innovatetech,dc=lan');
define('LDAP_USERS_OU', 'Usuaris');
define('LDAP_ADMIN_DN', 'cn=admin,dc=innovatetech,dc=lan');

// ── Configuració Base de Dades MySQL ───────────────────────────
define('DB_HOST', 'localhost');
define('DB_NAME', 'innovatetech');
define('DB_USER', 'appuser');
define('DB_PASS', 'ITB2026.');

// ── Rols disponibles ───────────────────────────────────────────
define('ROLS', ['admin', 'vendes', 'administracio', 'treballador']);