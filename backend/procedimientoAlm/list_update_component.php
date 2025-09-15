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
$imagenes      = $data['imagenes'] ?? []; // array de 4 posiciones (pueden ser null)
$offset        = $data['offset'] ?? null;
$limit         = $data['limit'] ?? null;

try {
    if ($action == 'listar') {
        // ✅ Listar con paginación opcional
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

        // Asegurarse que el array tenga exactamente 4 posiciones
        $imagenes = array_pad($imagenes, 4, null);
        $img1 = $imagenes[0] ?? null;
        $img2 = $imagenes[1] ?? null;
        $img3 = $imagenes[2] ?? null;
        $img4 = $imagenes[3] ?? null;

        // Validar que se envíe al menos un valor para actualizar
        if ($cantidad === null && $img1 === null && $img2 === null && $img3 === null && $img4 === null) {
            throw new Exception("No hay datos para actualizar");
        }

        // Llamar al procedimiento almacenado
        $stmt = $conn->prepare("CALL ActualizarComponenteFlexible(?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sissss", 
            $identificador, 
            $cantidad, 
            $img1, 
            $img2, 
            $img3, 
            $img4
        );
        $stmt->execute();

        $response = ["success" => true, "message" => "Componente actualizado correctamente"];
    }

} catch (Exception $e) {
    $response = ["success" => false, "message" => $e->getMessage()];
}

echo json_encode($response);
$conn->close();
?>
