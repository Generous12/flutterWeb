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

// Acción recibida desde el frontend
$accion = isset($data["accion"]) ? $data["accion"] : "";

// ======================================
// LISTAR COMPONENTES
// ======================================
if ($accion === "listar") {
    $limit    = isset($data["limit"]) ? intval($data["limit"]) : 10;
    $offset   = isset($data["offset"]) ? intval($data["offset"]) : 0;
    $busqueda = isset($data["busqueda"]) ? $data["busqueda"] : null;

    try {
        $stmt = $conn->prepare("CALL ListarComponentesPantallaATRI(?, ?, ?)");
        $stmt->bind_param("iis", $limit, $offset, $busqueda);
        $stmt->execute();

        $result = $stmt->get_result();
        $componentes = [];
        while ($row = $result->fetch_assoc()) {
            $componentes[] = [
                "id_componente"     => $row["id_componente"],
                "nombre_tipo"       => $row["nombre_tipo"],
                "codigo_inventario" => $row["codigo_inventario"],
                "total_atributos"   => $row["total_atributos"]
            ];
        }

        $response = [
            "success" => true,
            "data"    => $componentes
        ];

        $stmt->close();
        $conn->next_result(); 

    } catch (Exception $e) {
        $response = [
            "success" => false,
            "message" => "Error: " . $e->getMessage()
        ];
    }
}

// ======================================
// DETALLE COMPONENTE
// ======================================
elseif ($accion === "detalle") {
    $id_componente = isset($data["id_componente"]) ? intval($data["id_componente"]) : 0;

    try {
        $stmt = $conn->prepare("CALL DetalleComponenteATRI(?)");
        $stmt->bind_param("i", $id_componente);
        $stmt->execute();

        // Primer SELECT (cabecera)
        $result1 = $stmt->get_result();
        $cabecera = $result1->fetch_assoc();

        // Avanzar al segundo SELECT
        $stmt->next_result();
        $result2 = $stmt->get_result();
        $atributos = [];
        while ($row = $result2->fetch_assoc()) {
            $atributos[] = [
                "id_atributo"     => $row["id_atributo"],
                "nombre_atributo" => $row["nombre_atributo"],
                "tipo_dato"       => $row["tipo_dato"],
                "valor"           => $row["valor"]
            ];
        }

        $response = [
            "success"  => true,
            "cabecera" => $cabecera,
            "atributos"=> $atributos
        ];

        $stmt->close();
        $conn->next_result(); 

    } catch (Exception $e) {
        $response = [
            "success" => false,
            "message" => "Error: " . $e->getMessage()
        ];
    }
}

echo json_encode($response, JSON_UNESCAPED_UNICODE);
