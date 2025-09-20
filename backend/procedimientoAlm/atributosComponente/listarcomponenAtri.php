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

// Parámetros recibidos desde el frontend
$limit  = isset($data["limit"]) ? intval($data["limit"]) : 10;
$offset = isset($data["offset"]) ? intval($data["offset"]) : 0;

try {
    // Conexión mysqli
    $stmt = $conn->prepare("CALL ListarComponentesPantallaATRI(?, ?)");
    $stmt->bind_param("ii", $limit, $offset);
    $stmt->execute();

    $result = $stmt->get_result();

    $componentes = [];
    while ($row = $result->fetch_assoc()) {
        $componentes[] = [
            "id_componente"    => $row["id_componente"],
            "nombre_tipo"      => $row["nombre_tipo"],
            "codigo_inventario"=> $row["codigo_inventario"],
            "total_atributos"  => $row["total_atributos"]
        ];
    }

    $response = [
        "success" => true,
        "data"    => $componentes
    ];

    $stmt->close();
    $conn->next_result(); 

} catch (Exception $e) {
    $response = [
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE);
