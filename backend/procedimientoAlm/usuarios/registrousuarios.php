<?php
ob_start();
include __DIR__ . "/../../mysqlConexion.php"; 
include __DIR__ . "/../../funciones.php"; 
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

error_reporting(E_ERROR | E_PARSE);
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$data = json_decode(file_get_contents("php://input"), true);

$response = ["success" => false, "message" => "Acción no válida"];

$accion = isset($data["accion"]) ? $data["accion"] : "";

if ($accion === "registrarUsuario") {
    $id_usuario = $data["id_usuario"] ?? null;
    $nombre     = $data["nombre"] ?? null;
    $password   = $data["password"] ?? null; 
    $rol        = $data["rol"] ?? null;

    if ($id_usuario && $nombre && $password && $rol) {
        try {
            $passwordHash = password_hash($password, PASSWORD_BCRYPT);

            $stmt = $conn->prepare("CALL RegistrarUsuario(?, ?, ?, ?)");
            $stmt->bind_param("ssss", $id_usuario, $nombre, $passwordHash, $rol);
            $stmt->execute();
            $stmt->close();

            $accionHistorial = "Registro de nuevo usuario";
            $id_entidad = $id_usuario;

          registrarHistorial($conn, $id_usuario, $rol, $accionHistorial, $id_entidad);

            $response = [
                "success" => true,
                "message" => "Usuario registrado correctamente y acción guardada en historial"
            ];
        } catch (mysqli_sql_exception $e) {
            $response = [
                "success" => false,
                "message" => "Error: " . $e->getMessage()
            ];
        }
    } else {
        $response = [
            "success" => false,
            "message" => "Faltan parámetros"
        ];
    }
}

echo json_encode($response);
