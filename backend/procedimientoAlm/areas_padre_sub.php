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

try {  if ($accion === "crearAreaPadre") {

    $nombre = $data["nombre_area"] ?? "";
    $jefe = $data["jefe_area"] ?? null;
    $correo = $data["correo_contacto"] ?? null;
    $telefono = $data["telefono_contacto"] ?? null;
    $descripcion = $data["descripcion"] ?? null;

    $stmt = $conn->prepare(
        "CALL sp_crearAreaPadre(?, ?, ?, ?, ?, @id_area)"
    );
    $stmt->bind_param("sssss", $nombre, $jefe, $correo, $telefono, $descripcion);
    $stmt->execute();

    $result = $conn->query("SELECT @id_area AS id_area");
    $id_area = $result->fetch_assoc()["id_area"];

    $response = [
        "success" => true,
        "message" => "Área padre creada ✅",
        "id_area" => $id_area
    ];
}   elseif ($accion === "crearSubArea") {

    $nombre = $data["nombre_area"] ?? "";
    $id_padre = $data["id_area_padre"] ?? 0;

    $jefe = $data["jefe_area"] ?? null;
    $correo = $data["correo_contacto"] ?? null;
    $telefono = $data["telefono_contacto"] ?? null;
    $descripcion = $data["descripcion"] ?? null;

    $stmt = $conn->prepare(
        "CALL sp_crearSubArea(?, ?, ?, ?, ?, ?, @id_area)"
    );
    $stmt->bind_param("sissss", $nombre, $id_padre, $jefe, $correo, $telefono, $descripcion);
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

    // Parámetros obligatorios
    $id_padre = $data["id_area_padre"] ?? 0;
    $limit = $data["limit"] ?? 10;
    $offset = $data["offset"] ?? 0;

    //  Parámetros opcionales de actualización
    $id_area_actualizar = $data["id_area_actualizar"] ?? null;
    $jefe_area = $data["jefe_area"] ?? null;
    $correo_contacto = $data["correo_contacto"] ?? null;
    $telefono_contacto = $data["telefono_contacto"] ?? null;
    $descripcion = $data["descripcion"] ?? null;

    //  Llamada al PROCEDIMIENTO con 8 parámetros
    $stmt = $conn->prepare("CALL sp_detalleAreaPadre(?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param(
        "iiisssss",
        $id_padre,
        $limit,
        $offset,
        $id_area_actualizar,
        $jefe_area,
        $correo_contacto,
        $telefono_contacto,
        $descripcion
    );

    $stmt->execute();
    $result = $stmt->get_result();
    $areas = $result->fetch_all(MYSQLI_ASSOC);

    // Tu lógica original sigue igual (no la cambié)
    foreach ($areas as &$a) {
        if ($a["id_area_padre"] == $id_padre) {
            $a["tipo_area"] = "Subárea";
        } else {
            $a["tipo_area"] = "Sub-Subárea";
        }
    }

    $response = ["success" => true, "areas" => $areas];
}
elseif ($accion === "quitarAsignacionArea") {
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
    }elseif ($accion === "eliminarAreasSinSubniveles") {
    // Ejecutar el procedimiento almacenado
    if ($result = $conn->query("CALL EliminarAreasSinSubniveles()")) {

        // Obtener el resultado del SELECT dentro del procedimiento
        $row = $result->fetch_assoc();

        // Liberar el primer conjunto de resultados
        $result->close();

        // Liberar posibles resultados adicionales para evitar problemas con siguientes queries
        while ($conn->more_results() && $conn->next_result()) {
            $extraResult = $conn->use_result();
            if ($extraResult instanceof mysqli_result) {
                $extraResult->close();
            }
        }

        $response = [
            "success" => true,
            "message" => "Áreas padre sin subniveles eliminadas ✅",
            "total_eliminadas" => $row["total_eliminadas"] ?? 0
        ];
    } else {
        $response = [
            "success" => false,
            "message" => "Error al ejecutar el procedimiento: " . $conn->error
        ];
    }
}




} catch (Exception $e) {
    $response = ["success" => false, "message" => "⚠️ Error: " . $e->getMessage()];
}

echo json_encode($response, JSON_UNESCAPED_UNICODE);
$conn->close();
