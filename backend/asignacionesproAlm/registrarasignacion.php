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
$response = ["success" => false];

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {

        $id_case = $data["id_case"] ?? null;
        $id_area = $data["id_area"] ?? null;
        $componentes = $data["componentes"] ?? [];

        if (!$id_case || !$id_area) {
            throw new Exception("Faltan parámetros obligatorios (id_case, id_area).");
        }
        $componentes_json = json_encode($componentes, JSON_UNESCAPED_UNICODE);

        $stmt = $conn->prepare("CALL RegistrarAsignacion(?, ?, ?)");
        $stmt->bind_param("iis", $id_case, $id_area, $componentes_json);
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result ? $result->fetch_assoc() : null;

        while ($conn->more_results() && $conn->next_result()) {;}

        if ($row && isset($row["id_case_asignado"])) {
            $response = [
                "success" => true,
                "message" => "Asignación registrada correctamente",
                "id_case_asignado" => $row["id_case_asignado"]
            ];
        } else {
            throw new Exception("No se pudo obtener el ID de asignación.");
        }

        $stmt->close();

    } else {
        throw new Exception("Método no permitido.");
    }

} catch (Exception $e) {
    $response = [
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>
