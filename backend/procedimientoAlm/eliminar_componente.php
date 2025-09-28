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

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($data['ids'])) {
    $ids = $data['ids']; 

    try {
        $stmt = $conn->prepare("CALL EliminarTiposComponentesvarios(?)");
        $stmt->bind_param("s", $ids);
        $stmt->execute();
        $stmt->close();
        $response = [
            "success" => true,
            "message" => "Tipos de componente eliminados correctamente."
        ];
    } catch (mysqli_sql_exception $e) {
        $response = [
            "success" => false,
            "message" => "Error al eliminar: " . $e->getMessage()
        ];
    }
}

echo json_encode($response);
