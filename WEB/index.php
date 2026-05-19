<?php
// Innovate Tech - Projecte Transversal ASIXc1
// index.php — Panel principal de gestió

require_once 'auth.php';
require_once 'db.php';
verificarSesion();

// ── Carrega de dades per a cada secció ─────────────────────────
$seccio = $_GET['seccio'] ?? 'empleats';

$empleats     = [];
$departaments = [];
$videos       = [];
$trucades     = [];
$amplada      = [];

try {
    if ($seccio === 'empleats') {
        $empleats = $pdo->query("
            SELECT e.dni, e.nom, e.cognoms, e.telefon, e.email, e.estat,
                   d.nom_departament AS departament
            FROM empleats e
            LEFT JOIN departaments d ON e.codi_departament = d.codi
            ORDER BY e.cognoms, e.nom
        ")->fetchAll();
    }

    if ($seccio === 'departaments') {
        $departaments = $pdo->query("
            SELECT d.codi, d.nom_departament, d.telefon,
                   COUNT(e.dni) AS num_empleats
            FROM departaments d
            LEFT JOIN empleats e ON e.codi_departament = d.codi
            GROUP BY d.codi
            ORDER BY d.nom_departament
        ")->fetchAll();
    }

    if ($seccio === 'videos') {
        $videos = $pdo->query("
            SELECT id, titol, descripcio, categoria, durada_segons,
                   data_publicacio, url_streaming
            FROM videos_streaming
            ORDER BY data_publicacio DESC
        ")->fetchAll();
    }

    if ($seccio === 'trucades') {
        $trucades = $pdo->query("
            SELECT t.id, t.data_inici, t.durada_minuts, t.qualitat,
                   t.valoracio, t.estat,
                   eo.nom AS originador, eo.cognoms AS cognoms_orig,
                   ed.nom AS destinatari, ed.cognoms AS cognoms_dest
            FROM trucades t
            LEFT JOIN empleats eo ON t.usuari_originador = eo.dni
            LEFT JOIN empleats ed ON t.usuari_destinatari = ed.dni
            ORDER BY t.data_inici DESC
            LIMIT 50
        ")->fetchAll();
    }

    if ($seccio === 'amplada') {
        $amplada = $pdo->query("
            SELECT a.id, a.data_mesura, a.baixada_mbps, a.pujada_mbps,
                   a.latencia_ms, a.resultat, a.notes,
                   e.nom AS operari, e.cognoms AS cognoms_op
            FROM amplada_banda a
            LEFT JOIN empleats e ON a.usuari_mesura = e.dni
            ORDER BY a.data_mesura DESC
        ")->fetchAll();
    }
} catch (PDOException $e) {
    $db_error = $e->getMessage();
}

// ── Funció auxiliar per formatar durada ────────────────────────
function formatDurada(int $segons): string {
    $h = intdiv($segons, 3600);
    $m = intdiv($segons % 3600, 60);
    $s = $segons % 60;
    return $h > 0
        ? sprintf('%d h %02d min', $h, $m)
        : sprintf('%d min %02d s', $m, $s);
}
?>
<!DOCTYPE html>
<html lang="ca">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Innovate Tech — Panel de gestió</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'DM Sans', sans-serif; background: #0A0F1E; color: #E8ECF4; min-height: 100vh; }

    /* ── Navbar ── */
    nav {
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 40px; height: 60px;
      background: rgba(10,15,30,0.95);
      border-bottom: 0.5px solid rgba(255,255,255,0.08);
      position: sticky; top: 0; z-index: 100;
    }
    .logo { font-family: 'Syne',sans-serif; font-size: 18px; color:#fff; display:flex; align-items:center; gap:8px; }
    .logo-dot { width:8px; height:8px; border-radius:50%; background:#3B82F6; }
    .nav-user { display:flex; align-items:center; gap:16px; font-size:13px; }
    .badge-rol {
      background: rgba(59,130,246,0.15);
      border: 0.5px solid rgba(59,130,246,0.3);
      color: #93C5FD; font-size: 11px; padding: 3px 10px;
      border-radius: 100px;
    }
    .btn-logout {
      background: transparent; border: 0.5px solid rgba(255,255,255,0.2);
      color: rgba(232,236,244,0.6); font-size: 13px; padding: 6px 14px;
      border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif;
      text-decoration: none; transition: all 0.2s;
    }
    .btn-logout:hover { color: #fff; border-color: rgba(255,255,255,0.4); }

    /* ── Contingut ── */
    .container { max-width: 1200px; margin: 0 auto; padding: 32px 40px; }

    .page-title { font-family: 'Syne',sans-serif; font-size: 26px; color:#fff; margin-bottom: 6px; }
    .page-sub { font-size: 13px; color: rgba(232,236,244,0.4); margin-bottom: 28px; }

    /* ── Tabs ── */
    .tabs { display: flex; gap: 4px; margin-bottom: 28px; flex-wrap: wrap; }
    .tab {
      padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500;
      color: rgba(232,236,244,0.5); background: transparent;
      border: 0.5px solid transparent; text-decoration: none; transition: all 0.2s;
    }
    .tab:hover { color: #fff; background: rgba(255,255,255,0.05); }
    .tab.actiu {
      color: #93C5FD; background: rgba(59,130,246,0.12);
      border-color: rgba(59,130,246,0.3);
    }

    /* ── Taules ── */
    .table-wrap {
      background: rgba(255,255,255,0.03);
      border: 0.5px solid rgba(255,255,255,0.08);
      border-radius: 12px; overflow: hidden;
    }
    .table-header {
      display: flex; justify-content: space-between; align-items: center;
      padding: 16px 20px;
      border-bottom: 0.5px solid rgba(255,255,255,0.06);
    }
    .table-header h3 { font-size: 14px; font-weight: 500; color: #fff; }
    .count { font-size: 12px; color: rgba(232,236,244,0.4); }
    table { width: 100%; border-collapse: collapse; }
    thead tr { border-bottom: 0.5px solid rgba(255,255,255,0.06); }
    th {
      text-align: left; font-size: 11px; font-weight: 500;
      color: rgba(232,236,244,0.35); padding: 12px 20px;
      text-transform: uppercase; letter-spacing: 0.8px;
    }
    td { padding: 13px 20px; font-size: 13px; color: rgba(232,236,244,0.8); }
    tr:not(:last-child) td { border-bottom: 0.5px solid rgba(255,255,255,0.04); }
    tbody tr:hover { background: rgba(255,255,255,0.03); }

    /* ── Badges ── */
    .badge {
      display: inline-block; font-size: 11px; padding: 2px 9px;
      border-radius: 100px; font-weight: 500;
    }
    .badge-ok  { background: rgba(52,211,153,0.12); color: #6EE7B7; border: 0.5px solid rgba(52,211,153,0.25); }
    .badge-ko  { background: rgba(226,75,74,0.12);  color: #FCA5A5; border: 0.5px solid rgba(226,75,74,0.25); }
    .badge-alt { background: rgba(251,191,36,0.12); color: #FDE68A; border: 0.5px solid rgba(251,191,36,0.25); }
    .badge-mid { background: rgba(59,130,246,0.12); color: #93C5FD; border: 0.5px solid rgba(59,130,246,0.25); }

    /* ── Accions ── */
    .btn-action {
      font-size: 12px; color: rgba(232,236,244,0.4); text-decoration: none;
      padding: 4px 10px; border-radius: 5px; border: 0.5px solid transparent;
      transition: all 0.2s; display: inline-block;
    }
    .btn-action:hover { color: #fff; border-color: rgba(255,255,255,0.15); background: rgba(255,255,255,0.05); }
    .btn-del:hover { color: #FCA5A5; border-color: rgba(226,75,74,0.3); background: rgba(226,75,74,0.08); }

    .empty { padding: 40px; text-align: center; font-size: 13px; color: rgba(232,236,244,0.25); }

    .btn-new {
      background: #3B82F6; border: none; color: #fff; font-size: 13px; font-weight: 500;
      padding: 8px 16px; border-radius: 8px; cursor: pointer; text-decoration: none;
      font-family: 'DM Sans', sans-serif; transition: background 0.2s;
    }
    .btn-new:hover { background: #2563EB; }

    /* ── Stars valoració ── */
    .stars { color: #FBBF24; letter-spacing: 1px; }
  </style>
</head>
<body>

<nav>
  <div class="logo"><span class="logo-dot"></span> Innovate Tech</div>
  <div class="nav-user">
    <span style="color:rgba(232,236,244,0.6)">
      <?= htmlspecialchars($_SESSION['nom'] ?? $_SESSION['usuario']) ?>
    </span>
    <span class="badge-rol"><?= htmlspecialchars($_SESSION['rol']) ?></span>
    <a href="logout.php" class="btn-logout">Sortir</a>
  </div>
</nav>

<div class="container">
  <h1 class="page-title">Panel de gestió</h1>
  <p class="page-sub">Benvingut/da, <?= htmlspecialchars($_SESSION['nom'] ?? $_SESSION['usuario']) ?> · <?= date('d/m/Y H:i') ?></p>

  <!-- Tabs de navegació -->
  <div class="tabs">
    <a href="?seccio=empleats"     class="tab <?= $seccio==='empleats'     ? 'actiu':'' ?>">Empleats</a>
    <a href="?seccio=departaments" class="tab <?= $seccio==='departaments' ? 'actiu':'' ?>">Departaments</a>
    <a href="?seccio=videos"       class="tab <?= $seccio==='videos'       ? 'actiu':'' ?>">Vídeos streaming</a>
    <a href="?seccio=trucades"     class="tab <?= $seccio==='trucades'     ? 'actiu':'' ?>">Trucades</a>
    <a href="?seccio=amplada"      class="tab <?= $seccio==='amplada'      ? 'actiu':'' ?>">Amplada de banda</a>
  </div>

  <?php if (isset($db_error)): ?>
    <div style="background:rgba(226,75,74,0.1);border:0.5px solid rgba(226,75,74,0.3);border-radius:8px;padding:14px 18px;font-size:13px;color:#FCA5A5;margin-bottom:20px;">
      Error de base de dades: <?= htmlspecialchars($db_error) ?>
    </div>
  <?php endif; ?>

  <!-- ════════════ EMPLEATS ════════════ -->
  <?php if ($seccio === 'empleats'): ?>
  <div class="table-wrap">
    <div class="table-header">
      <h3>Empleats</h3>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="count"><?= count($empleats) ?> registres</span>
        <?php if (teRol('admin','administracio')): ?>
          <a href="crud.php?accio=nou&taula=empleats" class="btn-new">+ Nou empleat</a>
        <?php endif; ?>
      </div>
    </div>
    <?php if (empty($empleats)): ?>
      <p class="empty">No hi ha empleats a la base de dades.</p>
    <?php else: ?>
    <table>
      <thead>
        <tr>
          <th>DNI</th><th>Nom i cognoms</th><th>Departament</th>
          <th>Email</th><th>Telèfon</th><th>Estat</th>
          <?php if (teRol('admin','administracio')): ?><th>Accions</th><?php endif; ?>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($empleats as $e): ?>
        <tr>
          <td><code style="font-size:12px;opacity:.7"><?= htmlspecialchars($e['dni']) ?></code></td>
          <td><?= htmlspecialchars($e['cognoms'] . ', ' . $e['nom']) ?></td>
          <td><?= htmlspecialchars($e['departament'] ?? '—') ?></td>
          <td style="color:rgba(232,236,244,0.5)"><?= htmlspecialchars($e['email'] ?? '—') ?></td>
          <td><?= htmlspecialchars($e['telefon'] ?? '—') ?></td>
          <td>
            <?php if ($e['estat'] === 'actiu'): ?>
              <span class="badge badge-ok">Actiu</span>
            <?php else: ?>
              <span class="badge badge-ko">Bloquejat</span>
            <?php endif; ?>
          </td>
          <?php if (teRol('admin','administracio')): ?>
          <td>
            <a href="crud.php?accio=editar&taula=empleats&id=<?= urlencode($e['dni']) ?>" class="btn-action">Editar</a>
            <a href="crud.php?accio=eliminar&taula=empleats&id=<?= urlencode($e['dni']) ?>"
               class="btn-action btn-del"
               onclick="return confirm('Eliminar l\'empleat <?= htmlspecialchars($e['nom']) ?>?')">Eliminar</a>
          </td>
          <?php endif; ?>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <?php endif; ?>
  </div>

  <!-- ════════════ DEPARTAMENTS ════════════ -->
  <?php elseif ($seccio === 'departaments'): ?>
  <div class="table-wrap">
    <div class="table-header">
      <h3>Departaments</h3>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="count"><?= count($departaments) ?> registres</span>
        <?php if (teRol('admin','administracio')): ?>
          <a href="crud.php?accio=nou&taula=departaments" class="btn-new">+ Nou departament</a>
        <?php endif; ?>
      </div>
    </div>
    <?php if (empty($departaments)): ?>
      <p class="empty">No hi ha departaments a la base de dades.</p>
    <?php else: ?>
    <table>
      <thead>
        <tr>
          <th>Codi</th><th>Nom del departament</th><th>Telèfon</th>
          <th>Empleats</th>
          <?php if (teRol('admin','administracio')): ?><th>Accions</th><?php endif; ?>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($departaments as $d): ?>
        <tr>
          <td><code style="font-size:12px;opacity:.7"><?= htmlspecialchars($d['codi']) ?></code></td>
          <td><?= htmlspecialchars($d['nom_departament']) ?></td>
          <td><?= htmlspecialchars($d['telefon'] ?? '—') ?></td>
          <td><span class="badge badge-mid"><?= $d['num_empleats'] ?></span></td>
          <?php if (teRol('admin','administracio')): ?>
          <td>
            <a href="crud.php?accio=editar&taula=departaments&id=<?= urlencode($d['codi']) ?>" class="btn-action">Editar</a>
            <a href="crud.php?accio=eliminar&taula=departaments&id=<?= urlencode($d['codi']) ?>"
               class="btn-action btn-del"
               onclick="return confirm('Eliminar el departament?')">Eliminar</a>
          </td>
          <?php endif; ?>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <?php endif; ?>
  </div>

  <!-- ════════════ VIDEOS ════════════ -->
  <?php elseif ($seccio === 'videos'): ?>
  <div class="table-wrap">
    <div class="table-header">
      <h3>Catàleg de vídeos en streaming</h3>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="count"><?= count($videos) ?> registres</span>
        <?php if (teRol('admin','vendes')): ?>
          <a href="crud.php?accio=nou&taula=videos" class="btn-new">+ Nou vídeo</a>
        <?php endif; ?>
      </div>
    </div>
    <?php if (empty($videos)): ?>
      <p class="empty">No hi ha vídeos al catàleg.</p>
    <?php else: ?>
    <table>
      <thead>
        <tr>
          <th>Títol</th><th>Categoria</th><th>Durada</th>
          <th>Publicació</th><th>Streaming</th>
          <?php if (teRol('admin','vendes')): ?><th>Accions</th><?php endif; ?>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($videos as $v): ?>
        <tr>
          <td>
            <div style="font-weight:500;color:#fff"><?= htmlspecialchars($v['titol']) ?></div>
            <div style="font-size:12px;color:rgba(232,236,244,0.4);margin-top:2px"><?= htmlspecialchars(mb_strimwidth($v['descripcio'] ?? '', 0, 60, '…')) ?></div>
          </td>
          <td><span class="badge badge-mid"><?= htmlspecialchars($v['categoria'] ?? '—') ?></span></td>
          <td><?= formatDurada((int)($v['durada_segons'] ?? 0)) ?></td>
          <td style="color:rgba(232,236,244,0.5)"><?= htmlspecialchars(substr($v['data_publicacio'] ?? '', 0, 10)) ?></td>
          <td>
            <?php if ($v['url_streaming']): ?>
              <a href="<?= htmlspecialchars($v['url_streaming']) ?>" target="_blank"
                 style="color:#3B82F6;font-size:12px;text-decoration:none">▶ Reproduir</a>
            <?php else: ?>
              <span style="color:rgba(232,236,244,0.3);font-size:12px">—</span>
            <?php endif; ?>
          </td>
          <?php if (teRol('admin','vendes')): ?>
          <td>
            <a href="crud.php?accio=editar&taula=videos&id=<?= $v['id'] ?>" class="btn-action">Editar</a>
            <a href="crud.php?accio=eliminar&taula=videos&id=<?= $v['id'] ?>"
               class="btn-action btn-del"
               onclick="return confirm('Eliminar el vídeo?')">Eliminar</a>
          </td>
          <?php endif; ?>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <?php endif; ?>
  </div>

  <!-- ════════════ TRUCADES ════════════ -->
  <?php elseif ($seccio === 'trucades'): ?>
  <div class="table-wrap">
    <div class="table-header">
      <h3>Registre de trucades</h3>
      <span class="count"><?= count($trucades) ?> últimes trucades</span>
    </div>
    <?php if (empty($trucades)): ?>
      <p class="empty">No hi ha trucades registrades.</p>
    <?php else: ?>
    <table>
      <thead>
        <tr>
          <th>Data</th><th>Originador</th><th>Destinatari</th>
          <th>Durada</th><th>Qualitat</th><th>Valoració</th><th>Estat</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($trucades as $t): ?>
        <tr>
          <td style="color:rgba(232,236,244,0.5);font-size:12px"><?= htmlspecialchars(substr($t['data_inici'] ?? '', 0, 16)) ?></td>
          <td><?= htmlspecialchars(($t['cognoms_orig'] ?? '') . ', ' . ($t['originador'] ?? '—')) ?></td>
          <td><?= htmlspecialchars(($t['cognoms_dest'] ?? '') . ', ' . ($t['destinatari'] ?? '—')) ?></td>
          <td><?= (int)($t['durada_minuts'] ?? 0) ?> min</td>
          <td>
            <?php
              $q = $t['qualitat'] ?? '';
              $cls = match($q) { 'alta'=>'badge-ok', 'mitja'=>'badge-mid', default=>'badge-ko' };
            ?>
            <span class="badge <?= $cls ?>"><?= htmlspecialchars($q ?: '—') ?></span>
          </td>
          <td>
            <?php if ($t['valoracio']): ?>
              <span class="stars"><?= str_repeat('★', (int)$t['valoracio']) . str_repeat('☆', 5-(int)$t['valoracio']) ?></span>
            <?php else: ?>
              <span style="color:rgba(232,236,244,0.3)">—</span>
            <?php endif; ?>
          </td>
          <td>
            <?php $estat = $t['estat'] ?? 'finalitzada'; ?>
            <span class="badge <?= $estat==='activa' ? 'badge-alt' : 'badge-ok' ?>"><?= htmlspecialchars($estat) ?></span>
          </td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <?php endif; ?>
  </div>

  <!-- ════════════ AMPLADA DE BANDA ════════════ -->
  <?php elseif ($seccio === 'amplada'): ?>
  <div class="table-wrap">
    <div class="table-header">
      <h3>Mesures d'amplada de banda</h3>
      <div style="display:flex;align-items:center;gap:12px;">
        <span class="count"><?= count($amplada) ?> registres</span>
        <?php if (teRol('admin','treballador')): ?>
          <a href="crud.php?accio=nou&taula=amplada" class="btn-new">+ Nova mesura</a>
        <?php endif; ?>
      </div>
    </div>
    <?php if (empty($amplada)): ?>
      <p class="empty">No hi ha mesures registrades.</p>
    <?php else: ?>
    <table>
      <thead>
        <tr>
          <th>Data</th><th>Operari</th>
          <th>Baixada (Mbps)</th><th>Pujada (Mbps)</th>
          <th>Latència (ms)</th><th>Resultat</th><th>Notes</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($amplada as $a): ?>
        <tr>
          <td style="color:rgba(232,236,244,0.5);font-size:12px"><?= htmlspecialchars(substr($a['data_mesura'] ?? '', 0, 16)) ?></td>
          <td><?= htmlspecialchars(($a['cognoms_op'] ?? '') . ', ' . ($a['operari'] ?? '—')) ?></td>
          <td style="color:#6EE7B7;font-weight:500"><?= number_format((float)($a['baixada_mbps'] ?? 0), 1) ?></td>
          <td style="color:#93C5FD;font-weight:500"><?= number_format((float)($a['pujada_mbps'] ?? 0), 1) ?></td>
          <td><?= (int)($a['latencia_ms'] ?? 0) ?> ms</td>
          <td>
            <?php $res = $a['resultat'] ?? ''; ?>
            <span class="badge <?= $res==='acceptable' ? 'badge-ok' : 'badge-ko' ?>">
              <?= htmlspecialchars($res ?: '—') ?>
            </span>
          </td>
          <td style="font-size:12px;color:rgba(232,236,244,0.4)"><?= htmlspecialchars(mb_strimwidth($a['notes'] ?? '', 0, 50, '…')) ?></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <?php endif; ?>
  </div>
  <?php endif; ?>

</div><!-- /container -->
</body>
</html>