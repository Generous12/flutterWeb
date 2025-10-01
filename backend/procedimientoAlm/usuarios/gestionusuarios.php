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

$accion = isset($data["accion"]) ? $data["accion"] : "";
$id_usuario = isset($data["id_usuario"]) ? $data["id_usuario"] : null;
$nuevo_rol = isset($data["nuevo_rol"]) ? $data["nuevo_rol"] : null;
$nuevo_estado = isset($data["nuevo_estado"]) ? $data["nuevo_estado"] : null;

try {
    if (strtoupper($accion) === "ACTUALIZAR" || strtoupper($accion) === "ELIMINAR") {
        $conn->begin_transaction();
    }

    $stmt = $conn->prepare("CALL sp_gestion_usuarios(?, ?, ?, ?)");
    $stmt->bind_param("ssss", $accion, $id_usuario, $nuevo_rol, $nuevo_estado);
    $stmt->execute();

    if (strtoupper($accion) === "LISTAR") {
        $usuarios = [];
        do {
            if ($result = $stmt->get_result()) {
                while ($row = $result->fetch_assoc()) {
                    $usuarios[] = $row;
                }
                $result->free();
            }
        } while ($stmt->more_results() && $stmt->next_result());
        $response = ["success" => true, "data" => $usuarios];
    } else {
        $response = ["success" => true, "message" => ucfirst(strtolower($accion)) . " ejecutado correctamente"];
        $conn->commit(); 
    }

    $stmt->close();
} catch (Exception $e) {
    if (strtoupper($accion) === "ACTUALIZAR" || strtoupper($accion) === "ELIMINAR") {
        $conn->rollback(); 
    }
    $response = ["success" => false, "message" => $e->getMessage()];
}

echo json_encode($response);
