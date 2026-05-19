<?php
// Innovate Tech - Projecte Transversal ASIXc1
// crud.php — Operacions de creació, edició i eliminació

require_once 'auth.php';
require_once 'db.php';
verificarSesion();

$accio = $_GET['accio'] ?? '';
$taula = $_GET['taula'] ?? '';
$id    = $_GET['id']    ?? '';

// ── Permisos per taula i rol ──────────────────────────────────
$permisos = [
    'empleats'     => ['admin', 'administracio'],
    'departaments' => ['admin', 'administracio'],
    'videos'       => ['admin', 'vendes'],
    'amplada'      => ['admin', 'treballador'],
];

function checkPermis(string $taula, array $permisos): void {
    $rols = $permisos[$taula] ?? ['admin'];
    if (!teRol(...$rols)) {
        header("Location: index.php?seccio={$taula}&error=sense_permis");
        exit();
    }
}

// ── ELIMINAR ─────────────────────────────────────────────────
if ($accio === 'eliminar' && $taula && $id) {
    checkPermis($taula, $permisos);

    $queries = [
        'empleats'     => "DELETE FROM empleats WHERE dni = ?",
        'departaments' => "DELETE FROM departaments WHERE codi = ?",
        'videos'       => "DELETE FROM videos_streaming WHERE id = ?",
        'amplada'      => "DELETE FROM amplada_banda WHERE id = ?",
    ];

    if (isset($queries[$taula])) {
        try {
            $stmt = $pdo->prepare($queries[$taula]);
            $stmt->execute([$id]);
        } catch (PDOException $e) {
            header("Location: index.php?seccio={$taula}&error=" . urlencode($e->getMessage()));
            exit();
        }
    }
    header("Location: index.php?seccio={$taula}&ok=eliminat");
    exit();
}

// ── CREAR o EDITAR — processament del formulari POST ─────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    checkPermis($taula, $permisos);

    try {
        switch ($taula) {

            // ── Empleats ──────────────────────────────────────
            case 'empleats':
                $dni    = trim($_POST['dni'] ?? '');
                $nom    = trim($_POST['nom'] ?? '');
                $cog    = trim($_POST['cognoms'] ?? '');
                $adr    = trim($_POST['adreca'] ?? '');
                $tel    = trim($_POST['telefon'] ?? '');
                $email  = trim($_POST['email'] ?? '');
                $estat  = $_POST['estat'] ?? 'actiu';
                $depart = trim($_POST['codi_departament'] ?? '');

                if ($accio === 'nou') {
                    $stmt = $pdo->prepare("
                        INSERT INTO empleats (dni, nom, cognoms, adreca, telefon, email, estat, codi_departament)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    ");
                    $stmt->execute([$dni, $nom, $cog, $adr, $tel, $email, $estat, $depart]);
                } else {
                    $stmt = $pdo->prepare("
                        UPDATE empleats
                        SET nom=?, cognoms=?, adreca=?, telefon=?, email=?, estat=?, codi_departament=?
                        WHERE dni=?
                    ");
                    $stmt->execute([$nom, $cog, $adr, $tel, $email, $estat, $depart, $id]);
                }
                break;

            // ── Departaments ──────────────────────────────────
            case 'departaments':
                $codi   = trim($_POST['codi'] ?? '');
                $nom    = trim($_POST['nom_departament'] ?? '');
                $tel    = trim($_POST['telefon'] ?? '');

                if ($accio === 'nou') {
                    $stmt = $pdo->prepare("
                        INSERT INTO departaments (codi, nom_departament, telefon)
                        VALUES (?, ?, ?)
                    ");
                    $stmt->execute([$codi, $nom, $tel]);
                } else {
                    $stmt = $pdo->prepare("
                        UPDATE departaments SET nom_departament=?, telefon=? WHERE codi=?
                    ");
                    $stmt->execute([$nom, $tel, $id]);
                }
                break;

            // ── Vídeos ────────────────────────────────────────
            case 'videos':
                $titol     = trim($_POST['titol'] ?? '');
                $descripcio = trim($_POST['descripcio'] ?? '');
                $categoria = trim($_POST['categoria'] ?? '');
                $durada    = (int)($_POST['durada_segons'] ?? 0);
                $data      = $_POST['data_publicacio'] ?? date('Y-m-d');
                $url       = trim($_POST['url_streaming'] ?? '');

                if ($accio === 'nou') {
                    $stmt = $pdo->prepare("
                        INSERT INTO videos_streaming
                            (titol, descripcio, categoria, durada_segons, data_publicacio, url_streaming)
                        VALUES (?, ?, ?, ?, ?, ?)
                    ");
                    $stmt->execute([$titol, $descripcio, $categoria, $durada, $data, $url]);
                } else {
                    $stmt = $pdo->prepare("
                        UPDATE videos_streaming
                        SET titol=?, descripcio=?, categoria=?, durada_segons=?,
                            data_publicacio=?, url_streaming=?
                        WHERE id=?
                    ");
                    $stmt->execute([$titol, $descripcio, $categoria, $durada, $data, $url, $id]);
                }
                break;

            // ── Amplada de banda ──────────────────────────────
            case 'amplada':
                $baixada  = (float)($_POST['baixada_mbps'] ?? 0);
                $pujada   = (float)($_POST['pujada_mbps'] ?? 0);
                $latencia = (int)($_POST['latencia_ms'] ?? 0);
                $resultat = $_POST['resultat'] ?? 'acceptable';
                $notes    = trim($_POST['notes'] ?? '');
                $operari  = $_SESSION['usuario']; // el DNI de l'usuari connectat

                $stmt = $pdo->prepare("
                    INSERT INTO amplada_banda
                        (data_mesura, usuari_mesura, baixada_mbps, pujada_mbps, latencia_ms, resultat, notes)
                    VALUES (NOW(), ?, ?, ?, ?, ?, ?)
                ");
                $stmt->execute([$operari, $baixada, $pujada, $latencia, $resultat, $notes]);
                break;
        }
    } catch (PDOException $e) {
        header("Location: index.php?seccio={$taula}&error=" . urlencode($e->getMessage()));
        exit();
    }

    header("Location: index.php?seccio={$taula}&ok=desat");
    exit();
}

// ── MOSTRAR FORMULARI (GET) ───────────────────────────────────
checkPermis($taula, $permisos);

// Per a edicions, carrega les dades actuals
$dades = [];
if ($accio === 'editar' && $id) {
    $q = match($taula) {
        'empleats'     => "SELECT * FROM empleats WHERE dni=?",
        'departaments' => "SELECT * FROM departaments WHERE codi=?",
        'videos'       => "SELECT * FROM videos_streaming WHERE id=?",
        default        => null
    };
    if ($q) {
        $stmt = $pdo->prepare($q);
        $stmt->execute([$id]);
        $dades = $stmt->fetch() ?: [];
    }
}

// Departaments per al select d'empleats
$llista_departs = $pdo->query("SELECT codi, nom_departament FROM departaments ORDER BY nom_departament")->fetchAll();

$titol_form = match($accio) {
    'nou'    => 'Nou registre',
    'editar' => 'Editar registre',
    default  => 'Formulari'
};
?>
<!DOCTYPE html>
<html lang="ca">
<head>
  <meta charset="UTF-8">
  <title>Innovate Tech — <?= htmlspecialchars($titol_form) ?></title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'DM Sans', sans-serif; background: #0A0F1E; color: #E8ECF4; min-height: 100vh; }
    nav {
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 40px; height: 60px; background: rgba(10,15,30,0.95);
      border-bottom: 0.5px solid rgba(255,255,255,0.08);
    }
    .logo { font-family: 'Syne',sans-serif; font-size: 18px; color:#fff; display:flex; align-items:center; gap:8px; }
    .logo-dot { width:8px;height:8px;border-radius:50%;background:#3B82F6; }
    .container { max-width: 640px; margin: 48px auto; padding: 0 24px; }
    .card {
      background: rgba(255,255,255,0.03); border: 0.5px solid rgba(255,255,255,0.08);
      border-radius: 16px; padding: 32px;
    }
    h2 { font-family: 'Syne',sans-serif; font-size: 20px; color: #fff; margin-bottom: 6px; }
    .sub { font-size: 13px; color: rgba(232,236,244,0.4); margin-bottom: 28px; }
    .field { margin-bottom: 16px; }
    .field label { display:block; font-size:12px; color:rgba(232,236,244,0.5); margin-bottom:6px; }
    .field input, .field select, .field textarea {
      width: 100%; background: rgba(255,255,255,0.05);
      border: 0.5px solid rgba(255,255,255,0.12); border-radius: 8px;
      padding: 11px 14px; font-size: 14px; color: #E8ECF4;
      font-family: 'DM Sans', sans-serif; outline: none;
      transition: border-color 0.2s;
    }
    .field input:focus, .field select:focus, .field textarea:focus {
      border-color: rgba(59,130,246,0.6);
    }
    .field select option { background: #1a2035; }
    .field textarea { resize: vertical; min-height: 80px; }
    .row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .actions { display: flex; gap: 12px; margin-top: 24px; }
    .btn-submit {
      background: #3B82F6; border: none; color: #fff; font-size: 14px;
      font-weight: 500; padding: 12px 24px; border-radius: 8px;
      cursor: pointer; font-family: 'DM Sans', sans-serif; transition: background 0.2s;
    }
    .btn-submit:hover { background: #2563EB; }
    .btn-cancel {
      background: transparent; border: 0.5px solid rgba(255,255,255,0.15);
      color: rgba(232,236,244,0.6); font-size: 14px; padding: 12px 24px;
      border-radius: 8px; text-decoration: none; transition: all 0.2s;
    }
    .btn-cancel:hover { color: #fff; border-color: rgba(255,255,255,0.3); }
  </style>
</head>
<body>
<nav>
  <div class="logo"><span class="logo-dot"></span> Innovate Tech</div>
</nav>
<div class="container">
  <div class="card">
    <h2><?= htmlspecialchars($titol_form) ?> — <?= htmlspecialchars($taula) ?></h2>
    <p class="sub">Omple els camps i desa els canvis.</p>

    <form method="POST" action="crud.php?accio=<?= $accio ?>&taula=<?= $taula ?>&id=<?= urlencode($id) ?>">

      <?php if ($taula === 'empleats'): ?>
        <?php if ($accio === 'nou'): ?>
        <div class="field"><label>DNI *</label>
          <input type="text" name="dni" placeholder="00000000A" required maxlength="9"></div>
        <?php endif; ?>
        <div class="row">
          <div class="field"><label>Nom *</label>
            <input type="text" name="nom" value="<?= htmlspecialchars($dades['nom'] ?? '') ?>" required></div>
          <div class="field"><label>Cognoms *</label>
            <input type="text" name="cognoms" value="<?= htmlspecialchars($dades['cognoms'] ?? '') ?>" required></div>
        </div>
        <div class="field"><label>Adreça</label>
          <input type="text" name="adreca" value="<?= htmlspecialchars($dades['adreca'] ?? '') ?>"></div>
        <div class="row">
          <div class="field"><label>Telèfon</label>
            <input type="tel" name="telefon" value="<?= htmlspecialchars($dades['telefon'] ?? '') ?>"></div>
          <div class="field"><label>Email</label>
            <input type="email" name="email" value="<?= htmlspecialchars($dades['email'] ?? '') ?>"></div>
        </div>
        <div class="row">
          <div class="field"><label>Departament</label>
            <select name="codi_departament">
              <option value="">— Sense departament —</option>
              <?php foreach ($llista_departs as $dep): ?>
              <option value="<?= htmlspecialchars($dep['codi']) ?>"
                <?= ($dades['codi_departament'] ?? '') === $dep['codi'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($dep['nom_departament']) ?>
              </option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="field"><label>Estat</label>
            <select name="estat">
              <option value="actiu"    <?= ($dades['estat'] ?? 'actiu') === 'actiu'    ? 'selected':'' ?>>Actiu</option>
              <option value="bloquejat" <?= ($dades['estat'] ?? '') === 'bloquejat' ? 'selected':'' ?>>Bloquejat</option>
            </select>
          </div>
        </div>

      <?php elseif ($taula === 'departaments'): ?>
        <?php if ($accio === 'nou'): ?>
        <div class="field"><label>Codi *</label>
          <input type="text" name="codi" placeholder="DEPT01" required maxlength="10"></div>
        <?php endif; ?>
        <div class="field"><label>Nom del departament *</label>
          <input type="text" name="nom_departament" value="<?= htmlspecialchars($dades['nom_departament'] ?? '') ?>" required></div>
        <div class="field"><label>Telèfon</label>
          <input type="tel" name="telefon" value="<?= htmlspecialchars($dades['telefon'] ?? '') ?>"></div>

      <?php elseif ($taula === 'videos'): ?>
        <div class="field"><label>Títol *</label>
          <input type="text" name="titol" value="<?= htmlspecialchars($dades['titol'] ?? '') ?>" required></div>
        <div class="field"><label>Descripció</label>
          <textarea name="descripcio"><?= htmlspecialchars($dades['descripcio'] ?? '') ?></textarea></div>
        <div class="row">
          <div class="field"><label>Categoria</label>
            <select name="categoria">
              <?php foreach (['Formació','Comunicació','Marketing','Suport','Altres'] as $cat): ?>
              <option <?= ($dades['categoria'] ?? '') === $cat ? 'selected':'' ?>><?= $cat ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="field"><label>Durada (segons)</label>
            <input type="number" name="durada_segons" min="0"
                   value="<?= htmlspecialchars($dades['durada_segons'] ?? '0') ?>"></div>
        </div>
        <div class="row">
          <div class="field"><label>Data de publicació</label>
            <input type="date" name="data_publicacio"
                   value="<?= htmlspecialchars($dades['data_publicacio'] ?? date('Y-m-d')) ?>"></div>
          <div class="field"><label>URL Streaming</label>
            <input type="url" name="url_streaming"
                   placeholder="rtmp://..."
                   value="<?= htmlspecialchars($dades['url_streaming'] ?? '') ?>"></div>
        </div>

      <?php elseif ($taula === 'amplada'): ?>
        <div class="row">
          <div class="field"><label>Baixada (Mbps)</label>
            <input type="number" step="0.1" name="baixada_mbps" min="0" required></div>
          <div class="field"><label>Pujada (Mbps)</label>
            <input type="number" step="0.1" name="pujada_mbps" min="0" required></div>
        </div>
        <div class="row">
          <div class="field"><label>Latència (ms)</label>
            <input type="number" name="latencia_ms" min="0" required></div>
          <div class="field"><label>Resultat</label>
            <select name="resultat">
              <option value="acceptable">Acceptable</option>
              <option value="no acceptable">No acceptable</option>
            </select>
          </div>
        </div>
        <div class="field"><label>Notes</label>
          <textarea name="notes" placeholder="Observacions de la mesura..."></textarea></div>
      <?php endif; ?>

      <div class="actions">
        <button type="submit" class="btn-submit">Desar</button>
        <a href="index.php?seccio=<?= $taula ?>" class="btn-cancel">Cancel·lar</a>
      </div>
    </form>
  </div>
</div>
</body>
</html>