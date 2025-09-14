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

$action = $data['action'] ?? '';
$busqueda = $data['busqueda'] ?? '';
$identificador = $data['identificador'] ?? '';
$columna = $data['columna'] ?? '';
$valor = $data['valor'] ?? '';
$imagenes = $data['imagenes'] ?? []; 
$offset = $data['offset'] ?? null;
$limit = $data['limit'] ?? null;

try {
    if ($action == 'listar') {
        // Usamos un solo procedimiento con paginación opcional
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
            // Asegurarse de que 'imagenes' sea un array
            $row['imagenes'] = $row['imagenes'] ? json_decode($row['imagenes'], true) : [];
            $componentes[] = $row;
        }


        $response = ["success" => true, "data" => $componentes];

    } elseif ($action == 'actualizar') {
        // Actualizar cualquier columna de un componente
        $stmt = $conn->prepare("CALL ActualizarComponente(?, ?, ?)");
        $stmt->bind_param("sss", $identificador, $columna, $valor);
        $stmt->execute();

        $response = ["success" => true, "message" => "Componente actualizado"];

    } elseif ($action == 'actualizar_imagenes') {
        // Actualizar imágenes
        if (count($imagenes) != 4) {
            throw new Exception("Se requieren 4 imágenes");
        }

        $stmt = $conn->prepare("CALL ActualizarComponenteImagenes(?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $identificador, 
                          $imagenes[0], $imagenes[1], $imagenes[2], $imagenes[3]);
        $stmt->execute();

        $response = ["success" => true, "message" => "Imágenes actualizadas"];
    }

} catch (Exception $e) {
    $response = ["success" => false, "message" => $e->getMessage()];
}

echo json_encode($response);
$conn->close();
?>
