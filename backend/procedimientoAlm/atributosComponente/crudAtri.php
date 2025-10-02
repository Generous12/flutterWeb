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

// 🔹 Nuevos campos comunes para historial
$id_usuario = isset($data["id_usuario"]) ? $data["id_usuario"] : null;
$rol = isset($data["rol"]) ? $data["rol"] : null;

function registrarHistorial($conn, $id_usuario, $rol, $accionTexto, $idEntidad) {
    if ($id_usuario && $rol) {
        $stmtHistorial = $conn->prepare("CALL RegistrarHistorial(?, ?, ?, ?)");
        $stmtHistorial->bind_param("ssss", $id_usuario, $rol, $accionTexto, $idEntidad);
        $stmtHistorial->execute();
        $stmtHistorial->close();
    }
}

try {
    if ($accion === "insertar_atributo") {
        $id_tipo = $data["id_tipo"];
        $nombre = $data["nombre_atributo"];
        $tipo = $data["tipo_dato"];

        $stmt = $conn->prepare("CALL InsertarAtributoATRIBUTO(?, ?, ?)");
        $stmt->bind_param("iss", $id_tipo, $nombre, $tipo);
        $stmt->execute();

        $result = $stmt->get_result();
        if ($result) {
            $row = $result->fetch_assoc();
            $id_atributo = $row["id_atributo"];

            $response = [
                "success" => true,
                "message" => "Atributo insertado correctamente",
                "id_atributo" => $id_atributo,
                "id_usuario" => $id_usuario,
                "rol" => $rol
            ];

            registrarHistorial($conn, $id_usuario, $rol, "Insertó atributo '$nombre' (ID $id_atributo)", $id_atributo);

            $result->free();
        } else {
            $response = [
                "success" => false,
                "message" => "No se pudo obtener el id del atributo",
                "id_usuario" => $id_usuario,
                "rol" => $rol
            ];
        }
        $stmt->close();

    } else if ($accion === "actualizar_atributo") {
        $id = $data["id_atributo"];
        $nombre = $data["nombre_atributo"];
        $tipo = $data["tipo_dato"];

        $stmt = $conn->prepare("CALL ActualizarAtributoATRIBUTO(?, ?, ?)");
        $stmt->bind_param("iss", $id, $nombre, $tipo);
        $stmt->execute();
        $stmt->close();

        $response = [
            "success" => true,
            "message" => "Atributo actualizado correctamente",
            "id_usuario" => $id_usuario,
            "rol" => $rol
        ];

        registrarHistorial($conn, $id_usuario, $rol, "Actualizó atributo '$nombre' (ID $id)", $id);

    } else if ($accion === "guardar_valor") {
        $idComp = $data["id_componente"];
        $idAtr = $data["id_atributo"];
        $valor = $data["valor"];

        $stmt = $conn->prepare("CALL GuardarValorATRIBUTO(?, ?, ?)");
        $stmt->bind_param("iis", $idComp, $idAtr, $valor);
        $stmt->execute();
        $stmt->close();

        $response = [
            "success" => true,
            "message" => "Valor guardado correctamente",
            "id_usuario" => $id_usuario,
            "rol" => $rol
        ];

        registrarHistorial($conn, $id_usuario, $rol, "Guardó valor '$valor' en atributo ID $idAtr del componente ID $idComp", $idComp);

    } else if ($accion === "eliminar_atributo") {
        $id = $data["id_atributo"];

        $stmt = $conn->prepare("CALL EliminarAtributoATRIBUTO(?)");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $stmt->close();

        $response = [
            "success" => true,
            "message" => "Atributo eliminado correctamente",
            "id_usuario" => $id_usuario,
            "rol" => $rol
        ];

        registrarHistorial($conn, $id_usuario, $rol, "Eliminó el atributo con ID $id", $id);

    } else {
        $response = [
            "success" => false,
            "message" => "Acción no válida o no reconocida",
            "id_usuario" => $id_usuario,
            "rol" => $rol
        ];
    }

} catch (Exception $e) {
    $response = [
        "success" => false,
        "message" => "Error: " . $e->getMessage(),
        "id_usuario" => $id_usuario,
        "rol" => $rol
    ];
}

echo json_encode($response);
