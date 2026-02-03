<?php
$databaseUrl = getenv('DATABASE_URL');

if (!$databaseUrl) {
    echo "<h1>Falta DATABASE_URL</h1>";
    echo "<p>Configura la variable DATABASE_URL en Railway.</p>";
    exit;
}

$dbConfig = parse_url($databaseUrl);

$host   = $dbConfig['host'] ?? null;
$user   = $dbConfig['user'] ?? null;
$pass   = $dbConfig['pass'] ?? null;
$port   = $dbConfig['port'] ?? 5432;
$dbname = isset($dbConfig['path']) ? ltrim($dbConfig['path'], '/') : null;

if (!$host || !$user || !$dbname) {
    echo "<h1>DATABASE_URL inválida</h1>";
    echo "<pre>" . htmlspecialchars($databaseUrl) . "</pre>";
    exit;
}

// Soporte para ?sslmode=require
$sslmode = null;
if (!empty($dbConfig['query'])) {
    parse_str($dbConfig['query'], $q);
    $sslmode = $q['sslmode'] ?? null;
}

$dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
if ($sslmode) {
    $dsn .= ";sslmode=$sslmode";
}

try {
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "<h1>Conexión exitosa a PostgreSQL (Railway)</h1>";

    $stmt = $pdo->query("SELECT id, name FROM users ORDER BY id ASC");
    $users = $stmt->fetchAll();

    if ($users) {
        echo "<h3>Cuentas de usuarios:</h3><ul>";
        foreach ($users as $u) {
            echo "<li>ID: " . (int)$u['id'] . " - Nombre: " . htmlspecialchars($u['name']) . "</li>";
        }
        echo "</ul>";
    } else {
        echo "<p>No hay usuarios en la tabla.</p>";
    }

} catch (PDOException $e) {
    echo "<h1>Error de conexión</h1>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
}

