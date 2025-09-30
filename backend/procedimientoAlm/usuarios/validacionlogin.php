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
if ($accion === "login") {
    $nombre = $data["nombre"] ?? "";
    $password = $data["password"] ?? "";

    if (!empty($nombre) && !empty($password)) {
        $stmt = $conn->prepare("SELECT password_hash FROM Usuario WHERE nombre = ?");
        $stmt->bind_param("s", $nombre);
        $stmt->execute();
        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();

        if ($row && password_verify($password, $row['password_hash'])) {
            $response = ["success" => true, "message" => "Login exitoso"];
        } else {
            $response = ["success" => false, "message" => "Usuario o contraseña incorrectos"];
        }
    } else {
        $response = ["success" => false, "message" => "Faltan datos"];
    }
}


echo json_encode($response);
?>
