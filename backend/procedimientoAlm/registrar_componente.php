<?php
ob_start();
include __DIR__ . "/../mysqlConexion.php";

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');

error_reporting(E_ERROR | E_PARSE);
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$data = json_decode(file_get_contents("php://input"), true);

// Validar parámetros
$missingParams = [];
if (!isset($data['nombre_tipo'])) $missingParams[] = 'nombre_tipo';
if (!isset($data['atributos']) || !is_array($data['atributos'])) $missingParams[] = 'atributos';
if (!isset($data['codigo_inventario'])) $missingParams[] = 'codigo_inventario';
if (!isset($data['cantidad'])) $missingParams[] = 'cantidad';

if (!empty($missingParams)) {
    $msg = "Faltan parámetros: " . implode(", ", $missingParams);
    error_log("❌ $msg");
    echo json_encode([
        "success" => false,
        "message" => $msg
    ]);
    exit;
}

$nombre_tipo = $data['nombre_tipo'];
$atributos = $data['atributos'];
$codigo_inventario = $data['codigo_inventario'];
$cantidad = intval($data['cantidad']);
$tipo_nombre = $data['tipo_nombre'];
try {
    $conn->begin_transaction();
    error_log("➡️ Iniciando transacción para crear componente");

    // 1️ Crear Tipo_Componente
    error_log("➡️ Creando Tipo_Componente: $nombre_tipo");
    $stmt = $conn->prepare("CALL sp_crearTipoComponente(?, @id_tipo)");
    if (!$stmt) { error_log("❌ Error prepare Tipo_Componente: ".$conn->error); }
    $stmt->bind_param("s", $nombre_tipo);
    $stmt->execute();
    $stmt->close();
    $result = $conn->query("SELECT @id_tipo as id_tipo");
    $id_tipo = $result->fetch_assoc()['id_tipo'];
    error_log("✅ Tipo_Componente creado con id: $id_tipo");

    // 2 Crear Atributos
    $atributos_db = [];
    foreach ($atributos as $attr) {
        $nombre_attr = $attr['nombre'];
        $tipo_dato = $attr['tipo_dato'];

        error_log("➡️ Agregando atributo: $nombre_attr, tipo: $tipo_dato");
        $stmt = $conn->prepare("CALL sp_agregarAtributo(?, ?, ?, @id_atributo)");
        if (!$stmt) { error_log("❌ Error prepare Atributo: ".$conn->error); }
        $stmt->bind_param("iss", $id_tipo, $nombre_attr, $tipo_dato);
        $stmt->execute();
        $stmt->close();

        $result = $conn->query("SELECT @id_atributo as id_atributo");
        $id_atributo = $result->fetch_assoc()['id_atributo'];
        error_log("✅ Atributo creado con id: $id_atributo");

        $atributos_db[] = [
            'id_atributo' => $id_atributo,
            'nombre' => $nombre_attr,
            'tipo_dato' => $tipo_dato,
            'valor' => $attr['valor'] ?? ''
        ];
    }
    $imagenes_json = !empty($data['imagenes']) ? json_encode($data['imagenes']) : '';


    // 3️ Crear Componente
    $stmt = $conn->prepare("CALL sp_crearComponenteInCan(?,?,?,?,?, @id_componente)");
    if (!$stmt) { error_log("❌ Error prepare Componente: ".$conn->error); }

    // Tipos: i = INT, s = STRING
    // id_tipo -> i, codigo_inventario -> s, cantidad -> i, imagenes_json -> s
    $stmt->bind_param("isiss", $id_tipo, $codigo_inventario, $cantidad, $imagenes_json, $tipo_nombre);

    $stmt->execute();
    $stmt->close();
    $result = $conn->query("SELECT @id_componente as id_componente");
    $id_componente = $result->fetch_assoc()['id_componente'];

    // 4️ Crear Valores de Atributos
    foreach ($atributos_db as $attr) {
        if (!empty($attr['valor'])) {
            error_log("➡️ Agregando valor para atributo {$attr['id_atributo']}: {$attr['valor']}");
            $stmt = $conn->prepare("CALL sp_agregarValorAtributo(?, ?, ?)");
            if (!$stmt) { error_log("❌ Error prepare ValorAtributo: ".$conn->error); }
            $stmt->bind_param("iis", $id_componente, $attr['id_atributo'], $attr['valor']);
            $stmt->execute();
            $stmt->close();
        }
    }

    $conn->commit();
    error_log("✅ Transacción completada correctamente");
    echo json_encode([
        "success" => true,
        "id_tipo" => $id_tipo,
        "id_componente" => $id_componente,
        "atributos" => $atributos_db
    ]);

} catch (Exception $e) {
    $conn->rollback();
    error_log("💥 Excepción en PHP: " . $e->getMessage());
    ob_start();
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}

$conn->close();
?>
