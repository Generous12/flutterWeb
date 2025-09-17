<?php
ob_start();
include __DIR__ . "/../mysqlConexion.php"; 

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

error_reporting(E_ERROR | E_PARSE);
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$data = json_decode(file_get_contents("php://input"), true);
$response = ["success" => false, "message" => "Acción no válida"];

$action        = $data['action'] ?? '';
$busqueda      = $data['busqueda'] ?? '';
$identificador = $data['identificador'] ?? '';
$cantidad      = $data['cantidad'] ?? null;
$imagenes      = $data['imagenes'] ?? []; 
$offset        = $data['offset'] ?? null;
$limit         = $data['limit'] ?? null;

try {
    if ($action == 'listar') {
        if ($offset !== null && $limit !== null) {
            $stmt = $conn->prepare("
                SELECT DISTINCT
                    c.id_componente,
                    c.codigo_inventario,
                    c.cantidad,
                    c.imagenes,
                    tc.nombre_tipo
                FROM Componente c
                INNER JOIN Tipo_Componente tc ON c.id_tipo = tc.id_tipo
                WHERE c.codigo_inventario LIKE CONCAT('%', ?, '%')
                   OR tc.nombre_tipo LIKE CONCAT('%', ?, '%')
                LIMIT ?, ?
            ");
            $stmt->bind_param("ssii", $busqueda, $busqueda, $offset, $limit);
        } else {
            $stmt = $conn->prepare("
                SELECT DISTINCT
                    c.id_componente,
                    c.codigo_inventario,
                    c.cantidad,
                    c.imagenes,
                    tc.nombre_tipo
                FROM Componente c
                INNER JOIN Tipo_Componente tc ON c.id_tipo = tc.id_tipo
                WHERE c.codigo_inventario LIKE CONCAT('%', ?, '%')
                   OR tc.nombre_tipo LIKE CONCAT('%', ?, '%')
            ");
            $stmt->bind_param("ss", $busqueda, $busqueda);
        }

        $stmt->execute();
        $result = $stmt->get_result();
        $componentes = [];
        while ($row = $result->fetch_assoc()) {
            $row['imagenes'] = $row['imagenes'] ? json_decode($row['imagenes'], true) : [];
            $componentes[] = $row;
        }

        $response = ["success" => true, "data" => $componentes];

  } elseif ($action == 'actualizar') {

    // ✅ Asegurar que siempre tengamos 4 posiciones
    $imagenes = array_pad($imagenes, 4, null);

    // 🔹 Traer imágenes actuales de la BD
    $stmtSel = $conn->prepare("SELECT imagenes FROM Componente WHERE codigo_inventario = ?");
    $stmtSel->bind_param("s", $identificador);
    $stmtSel->execute();
    $result = $stmtSel->get_result();
    $row = $result->fetch_assoc();

    // Decodificar las imágenes actuales (JSON → array)
    $imagenesActuales = json_decode($row['imagenes'], true);
    if (!$imagenesActuales) {
        $imagenesActuales = [null, null, null, null];
    }

    // 🔹 Reemplazar solo si Flutter mandó algo
    // - null  → mantener
    // - ""    → eliminar
    // - base64→ actualizar
    for ($i = 0; $i < 4; $i++) {
        if ($imagenes[$i] !== null) {
            $imagenesActuales[$i] = $imagenes[$i]; 
        }
    }

    // Codificar de nuevo a JSON
    $imagenesJson = json_encode($imagenesActuales);

    // Verificar que haya algo para actualizar
    if ($cantidad === null && $imagenesJson === $row['imagenes']) {
        throw new Exception("No hay datos para actualizar");
    }

    // ✅ Actualizar registro
    $stmt = $conn->prepare("UPDATE Componente SET cantidad = ?, imagenes = ? WHERE codigo_inventario = ?");
    $stmt->bind_param("iss", $cantidad, $imagenesJson, $identificador);
    $stmt->execute();

    $response = ["success" => true, "message" => "Componente actualizado correctamente"];
}



} catch (Exception $e) {
    $response = ["success" => false, "message" => $e->getMessage()];
}

echo json_encode($response);
$conn->close();
?>
