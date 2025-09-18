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
            $row['imagenes'] = $row['imagenes'] 
                ? array_values(json_decode($row['imagenes'], true)) 
                : [];
            $componentes[] = $row;
        }

        $response = ["success" => true, "data" => $componentes];

    } elseif ($action == 'actualizar') {
        $imagenes = array_pad($imagenes, 4, null);

        $stmtSel = $conn->prepare("SELECT cantidad, imagenes FROM Componente WHERE codigo_inventario = ?");
        $stmtSel->bind_param("s", $identificador);
        $stmtSel->execute();
        $result = $stmtSel->get_result();
        $row = $result->fetch_assoc();

        $cantidadActual = $row['cantidad'];
        $imagenesActuales = json_decode($row['imagenes'], true);
        if (!$imagenesActuales) {
            $imagenesActuales = [null, null, null, null];
        }
        for ($i = 0; $i < 4; $i++) {
            if ($imagenes[$i] !== null) {
                if ($imagenes[$i] === "") {
                    // Si es string vacío, eliminar (poner null)
                    $imagenesActuales[$i] = null;
                } else {
                    // Si es base64, actualizar/agregar
                    $imagenesActuales[$i] = $imagenes[$i];
                }
            }
        }


        $imagenesJson = json_encode($imagenesActuales);

        if ($cantidad === null) {
            $cantidad = $cantidadActual;
        }

        if ($cantidad == $cantidadActual && $imagenesJson === $row['imagenes']) {
            throw new Exception("No hay datos para actualizar");
        }

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
