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
    if (!isset($data["accion"])) {
        throw new Exception("No se especificó la acción.");
    }

    $accion = $data["accion"];

    switch ($accion) {

        case "listar":

            $id_area = $data["id_area"] ?? null;
            $limit = $data["limit"] ?? 10;
            $offset = $data["offset"] ?? 0;
            $busqueda = $data["busqueda"] ?? "";

            if (!$id_area) {
                throw new Exception("Falta el parámetro id_area.");
            }

            $stmt = $conn->prepare("CALL sp_listarCasesasginadoAunaArea(?, ?, ?, ?)");
            $stmt->bind_param("iiis", $id_area, $limit, $offset, $busqueda);
            $stmt->execute();

            $result = $stmt->get_result();
            $cases = [];

            while ($row = $result->fetch_assoc()) {
                $cases[] = $row;
            }

            while ($conn->more_results() && $conn->next_result()) {;}

            $response = [
                "success" => true,
                "message" => "Cases listados correctamente.",
                "data" => $cases
            ];

            $stmt->close();
            break;

        case "detalle":

            $id_case_asignado = $data["id_case_asignado"] ?? null;

            if (!$id_case_asignado) {
                throw new Exception("Falta el parámetro id_case_asignado.");
            }

            $stmt = $conn->prepare("CALL sp_detalleCaseAsignado(?)");
            $stmt->bind_param("i", $id_case_asignado);
            $stmt->execute();

            //  1er SELECT → Información del CASE principal
            $result1 = $stmt->get_result();
            $case_info = $result1->fetch_assoc();

            //  2do SELECT → Componentes secundarios
            $stmt->next_result();
            $result2 = $stmt->get_result();

            $componentes = [];
            while ($row = $result2->fetch_assoc()) {
                $componentes[] = $row;
            }

            while ($conn->more_results() && $conn->next_result()) {;}

            $response = [
                "success" => true,
                "message" => "Detalle del case obtenido correctamente.",
                "case" => $case_info,
                "componentes" => $componentes
            ];

            $stmt->close();
            break;


        default:
            throw new Exception("Acción no válida.");

    }

} catch (Exception $e) {
    $response = [
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
