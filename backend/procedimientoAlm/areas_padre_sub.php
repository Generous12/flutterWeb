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

$accion = $data["accion"] ?? "";

try {
    if ($accion === "crearAreaPadre") {
        $nombre = $data["nombre_area"] ?? "";
        $stmt = $conn->prepare("CALL sp_crearAreaPadre(?, @id_area)");
        $stmt->bind_param("s", $nombre);
        $stmt->execute();

        $result = $conn->query("SELECT @id_area AS id_area");
        $id_area = $result->fetch_assoc()["id_area"];

        $response = ["success" => true, "message" => "Área padre creada ✅", "id_area" => $id_area];
    }


    elseif ($accion === "crearSubArea") {
        $nombre = $data["nombre_area"] ?? "";
        $id_padre = $data["id_area_padre"] ?? 0;

        $stmt = $conn->prepare("CALL sp_crearSubArea(?, ?, @id_area)");
        $stmt->bind_param("si", $nombre, $id_padre);
        $stmt->execute();

        $result = $conn->query("SELECT @id_area AS id_area");
        $id_area = $result->fetch_assoc()["id_area"];

        if ($id_area) {
            $response = ["success" => true, "message" => "Subárea creada ✅", "id_area" => $id_area];
        } else {
            $response = ["success" => false, "message" => "❌ Área padre no existe"];
        }
    }

    elseif ($accion === "listarAreasPadres") {
        $result = $conn->query("CALL sp_listarAreasPadres()");
        $areas = $result->fetch_all(MYSQLI_ASSOC);

        $response = ["success" => true, "areas" => $areas];
    }


elseif ($accion === "listarAreasPadresGeneral") {
    $limit = $data["limit"] ?? 10;
    $offset = $data["offset"] ?? 0;
    $busqueda = $data["busqueda"] ?? null;

   
    if ($busqueda === "") {
        $busqueda = null;
    }

    $stmt = $conn->prepare("CALL sp_listarAreasPadresGeneral(?, ?, ?)");
    $stmt->bind_param("iis", $limit, $offset, $busqueda);
    $stmt->execute();

    $result = $stmt->get_result();
    $areas = $result->fetch_all(MYSQLI_ASSOC);

    $response = ["success" => true, "areas" => $areas];
}elseif ($accion === "listarSubAreasPorPadre") {
    $id_padre = $data["id_area_padre"] ?? 0;

    $stmt = $conn->prepare("CALL sp_listarSubAreasPorPadre(?)");
    $stmt->bind_param("i", $id_padre);
    $stmt->execute();

    $result = $stmt->get_result();
    $subareas = $result->fetch_all(MYSQLI_ASSOC);

    $response = ["success" => true, "subareas" => $subareas];
} elseif ($accion === "detalleAreaPadre") {
    $id_padre = $data["id_area_padre"] ?? 0;
    $limit = $data["limit"] ?? 10;
    $offset = $data["offset"] ?? 0;

    $stmt = $conn->prepare("CALL sp_detalleAreaPadre(?, ?, ?)");
    $stmt->bind_param("iii", $id_padre, $limit, $offset);
    $stmt->execute();

    $result = $stmt->get_result();
    $areas = $result->fetch_all(MYSQLI_ASSOC);

    foreach ($areas as &$a) {
        if ($a["id_area_padre"] == $id_padre) {
            $a["tipo_area"] = "Subárea";
        } else {
            $a["tipo_area"] = "Sub-Subárea";
        }
    }

    $response = ["success" => true, "areas" => $areas];
} elseif ($accion === "quitarAsignacionArea") {
        $id_area = $data["id_area"] ?? 0;

        $stmt = $conn->prepare("CALL sp_quitarAsignacionArea(?)");
        $stmt->bind_param("i", $id_area);
        $stmt->execute();

        $response = ["success" => true, "message" => "Asignación eliminada ✅"];
    }elseif ($accion === "asignarAreaPadre") {
    $id_area = $data["id_area"] ?? 0;
    $id_area_padre = $data["id_area_padre"] ?? 0;

    $stmt = $conn->prepare("CALL sp_asignarAreaPadre(?, ?)");
    $stmt->bind_param("ii", $id_area, $id_area_padre);
    $stmt->execute();

    $response = ["success" => true, "message" => "Área asignada correctamente ✅"];
}


} catch (Exception $e) {
    $response = ["success" => false, "message" => "⚠️ Error: " . $e->getMessage()];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE);
$conn->close();
