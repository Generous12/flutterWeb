<?php
include __DIR__ . "/mysqlConexion.php";

function registrarHistorial($conn, $id_usuario, $rol, $accion, $id_entidad) {
    $stmt = $conn->prepare("CALL RegistrarHistorial(?, ?, ?, ?)");
    $stmt->bind_param("ssss", $id_usuario, $rol, $accion, $id_entidad);
    $stmt->execute();
    $stmt->close();
}
?>