<?php
ob_start();
include __DIR__ . "/../mysqlConexion.php"; 
include __DIR__ . "/../funciones.php"; 
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

error_reporting(E_ERROR | E_PARSE);
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$data = json_decode(file_get_contents("php://input"), true);
$response = ["success" => false, "message" => "Acción no válida"];

$action        = $data['action'] ?? '';
$busqueda      = $data['busqueda'] ?? '';
$tipo              = $data['tipo'] ?? 'General';
$identificador = $data['identificador'] ?? '';
$cantidad      = $data['cantidad'] ?? null;
$imagenes      = $data['imagenes'] ?? []; 
$offset        = $data['offset'] ?? null;
$limit         = $data['limit'] ?? null;
$nuevo_tipo_nombre = $data['nuevo_tipo_nombre'] ?? null;
$estado            = $data['nuevoestado'] ?? null;
try {
if ($action == 'listar') {
    // Parámetros recibidos del cuerpo JSON
    $busqueda = $data['busqueda'] ?? '';
    $tipo = $data['tipo'] ?? 'General';
    $offset = isset($data['offset']) ? intval($data['offset']) : null;
    $limit = isset($data['limit']) ? intval($data['limit']) : null;
    $estado_asignacion = $data['estado_asignacion'] ?? null;

    if ($offset !== null && $limit !== null) {
        $stmt = $conn->prepare("CALL ListarComponentesPaginado(?, ?, ?, ?, ?)");
        $stmt->bind_param("ssiis", $busqueda, $tipo, $offset, $limit, $estado_asignacion);
    } else {
        // Si no hay paginación, usa valores por defecto (-1, -1 para que entre en el ELSE del procedimiento)
        $stmt = $conn->prepare("CALL ListarComponentesPaginado(?, ?, ?, ?, ?)");
        $fakeOffset = -1;
        $fakeLimit = -1;
        $stmt->bind_param("ssiis", $busqueda, $tipo, $fakeOffset, $fakeLimit, $estado_asignacion);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $componentes = [];
    while ($row = $result->fetch_assoc()) {
        $imagenes = json_decode($row['imagenes'], true) ?: [];
        $imagenesNum = [null, null, null, null];
        for ($i = 0; $i < 4; $i++) {
            if (isset($imagenes[$i])) {
                $imagenesNum[$i] = $imagenes[$i];
            }
        }
        $row['imagenes'] = $imagenesNum;
        $componentes[] = $row;
    }

    $response = ["success" => true, "data" => $componentes];
}

 elseif ($action == 'actualizar') {
    $nuevo_codigo = $data['nuevo_codigo'] ?? null;
    $nuevo_nombre_tipo = $data['nuevo_nombre_tipo'] ?? null;
    $idUsuarioCreador = $data['id_usuario'] ?? null;
    $rolCreador       = $data['rol'] ?? null;
    $imagenes = array_pad($imagenes, 4, null);
    $stmtSel = $conn->prepare("SELECT estado, imagenes, codigo_inventario, id_tipo, tipo_nombre FROM Componente WHERE codigo_inventario = ?");
    $stmtSel->bind_param("s", $identificador);
    $stmtSel->execute();
    $result = $stmtSel->get_result();
    $row = $result->fetch_assoc();

    if (!$row) {
        throw new Exception("Componente no encontrado");
    }

    $estadoActual = $row['estado'];
    $imagenesActuales = json_decode($row['imagenes'], true) ?: [null, null, null, null];
    $codigoActual = $row['codigo_inventario'];
    $tipoNombreActual = $row['tipo_nombre'];

    for ($i = 0; $i < 4; $i++) {
        if ($imagenes[$i] !== null) {
            $imagenesActuales[$i] = ($imagenes[$i] === "") ? null : $imagenes[$i];
        }
    }
    $imagenesJson = json_encode($imagenesActuales);
     $estadoAActualizar    = $estado ?? $estadoActual;
    $codigoAActualizar = $nuevo_codigo ?? $codigoActual;
    $tipoNombreAActualizar = $nuevo_tipo_nombre ?? $tipoNombreActual;
    $stmt = $conn->prepare("UPDATE Componente SET estado = ?, imagenes = ?, codigo_inventario = ?, tipo_nombre = ?  WHERE codigo_inventario = ?");
    $stmt->bind_param("sssss", $estadoAActualizar, $imagenesJson, $codigoAActualizar, $tipoNombreAActualizar, $identificador);
    $stmt->execute();

    if ($nuevo_nombre_tipo !== null && $nuevo_nombre_tipo !== '') {
        $stmtTipo = $conn->prepare("UPDATE Tipo_Componente SET nombre_tipo = ? WHERE id_tipo = ?");
        $stmtTipo->bind_param("si", $nuevo_nombre_tipo, $row['id_tipo']);
        $stmtTipo->execute();
    }
       if ($idUsuarioCreador && $rolCreador) {
        $accion = "Actualizó el componente con código " . $identificador;
        $idEntidad = $identificador;

        $stmtHistorial = $conn->prepare("CALL RegistrarHistorial(?, ?, ?, ?)");
        $stmtHistorial->bind_param("ssss", $idUsuarioCreador, $rolCreador, $accion, $idEntidad);
        $stmtHistorial->execute();
    }
    $response = ["success" => true, "message" => "Componente actualizado correctamente"];
}



} catch (Exception $e) {
    $response = ["success" => false, "message" => $e->getMessage()];
}

echo json_encode($response);
$conn->close();
?>