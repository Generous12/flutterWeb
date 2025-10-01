<?php 
ob_start();
include __DIR__ . "/../../mysqlConexion.php"; 

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

error_reporting(E_ERROR | E_PARSE);
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$data = json_decode(file_get_contents("php://input"), true);

$response = ["success" => false, "message" => "Acción no válida"];

$accion = isset($data["accion"]) ? strtoupper($data["accion"]) : "";
$ids_eliminar = isset($data["ids"]) ? $data["ids"] : []; 

$page = isset($data["page"]) ? (int)$data["page"] : 1;
$limit = isset($data["limit"]) ? (int)$data["limit"] : 30;
$offset = ($page - 1) * $limit;

try {
    if ($accion === "LISTAR") {
        $stmt = $conn->prepare("SELECT * FROM Historial_Acciones ORDER BY fecha DESC LIMIT ?, ?");
        $stmt->bind_param("ii", $offset, $limit);
        $stmt->execute();
        $result = $stmt->get_result();
        $historial = [];
        while ($row = $result->fetch_assoc()) {
            $historial[] = $row;
        }
        $stmt->close();
        $response = ["success" => true, "data" => $historial, "page" => $page];
    } elseif ($accion === "ELIMINAR") {
        if (!empty($ids_eliminar)) {
            $conn->begin_transaction();

            $ids_str = implode(",", array_map(fn($id) => "'$id'", $ids_eliminar));
            $sql = "DELETE FROM Historial_Acciones WHERE id_historial IN ($ids_str)";
            $conn->query($sql);

            $conn->commit();
            $response = ["success" => true, "message" => "Registros eliminados correctamente"];
        } else {
            $response = ["success" => false, "message" => "No se recibieron IDs para eliminar"];
        }
    }
} catch (Exception $e) {
    if ($accion === "ELIMINAR") {
        $conn->rollback();
    }
    $response = ["success" => false, "message" => $e->getMessage()];
}

echo json_encode($response);

?>
