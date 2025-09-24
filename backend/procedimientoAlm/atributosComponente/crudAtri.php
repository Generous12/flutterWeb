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

try {
    switch ($accion) {
        case "insertar_atributo":
            $id_tipo = $data["id_tipo"];
            $nombre = $data["nombre_atributo"];
            $tipo = $data["tipo_dato"];

            $stmt = $conn->prepare("CALL InsertarAtributoATRI(?, ?, ?)");
            $stmt->bind_param("iss", $id_tipo, $nombre, $tipo);
            $stmt->execute();

            $result = $stmt->get_result()->fetch_assoc();

            $response = [
                "success" => true,
                "message" => "Atributo insertado correctamente",
                "id_atributo" => $result["id_atributo"]
            ];
            break;

        case "actualizar_atributo":
            $id = $data["id_atributo"];
            $nombre = $data["nombre_atributo"];
            $tipo = $data["tipo_dato"];

            $stmt = $conn->prepare("CALL ActualizarAtributoATRI(?, ?, ?)");
            $stmt->bind_param("iss", $id, $nombre, $tipo);
            $stmt->execute();

            $response = [
                "success" => true,
                "message" => "Atributo actualizado correctamente"
            ];
            break;

        case "guardar_valor":
            $idComp = $data["id_componente"];
            $idAtr = $data["id_atributo"];
            $valor = $data["valor"];

            $stmt = $conn->prepare("CALL GuardarValorATRI(?, ?, ?)");
            $stmt->bind_param("iis", $idComp, $idAtr, $valor);
            $stmt->execute();

            $response = [
                "success" => true,
                "message" => "Valor guardado correctamente"
            ];
            break;

        case "eliminar_atributo":
            $id = $data["id_atributo"];

            $stmt = $conn->prepare("CALL EliminarAtributoATRI(?)");
            $stmt->bind_param("i", $id);
            $stmt->execute();

            $response = [
                "success" => true,
                "message" => "Atributo eliminado correctamente"
            ];
            break;
    }
} catch (Exception $e) {
    $response = [
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ];
}

echo json_encode($response);
