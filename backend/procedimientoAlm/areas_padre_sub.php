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
if (!$conn) {
    echo json_encode(["success" => false, "message" => "❌ Error de conexión"]);
    exit;
}

try {
    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        $accion = $data["accion"] ?? "";    if ($accion === "crearAreaPadre") {
            $nombre = $data["nombre_area"] ?? null;

            if ($nombre) {
                $stmt = $conn->prepare("CALL sp_crearAreaPadre(?, @id_area)");
                $stmt->bind_param("s", $nombre);
                $stmt->execute();
                $stmt->close();

                $result = $conn->query("SELECT @id_area AS id_area");
                $row = $result->fetch_assoc();

                $response = [
                    "success" => true,
                    "message" => "Área padre creada correctamente",
                    "id_area" => $row["id_area"]
                ];
            } else {
                $response = ["success" => false, "message" => "Nombre de área requerido"];
            }
        }
        elseif ($accion === "crearSubArea") {
            $nombre = $data["nombre_area"] ?? null;
            $idPadre = $data["id_area_padre"] ?? null;

            if ($nombre && $idPadre) {
                $stmt = $conn->prepare("CALL sp_crearSubArea(?, ?, @id_area)");
                $stmt->bind_param("si", $nombre, $idPadre);
                $stmt->execute();
                $stmt->close();

                $result = $conn->query("SELECT @id_area AS id_area");
                $row = $result->fetch_assoc();

                if ($row["id_area"]) {
                    $response = [
                        "success" => true,
                        "message" => "Subárea creada correctamente",
                        "id_area" => $row["id_area"]
                    ];
                } else {
                    $response = ["success" => false, "message" => "El área padre no existe"];
                }
            } else {
                $response = ["success" => false, "message" => "Nombre e id_area_padre requeridos"];
            }
        }  elseif ($accion === "listarAreasPadres") {
            $result = $conn->query("CALL sp_listarAreasPadres()");
            $areas = [];

            while ($row = $result->fetch_assoc()) {
                $areas[] = $row;
            }

            $response = ["success" => true, "areas" => $areas];
        }
    }
} catch (Exception $e) {
    $response = ["success" => false, "message" => "Error: " . $e->getMessage()];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE);
