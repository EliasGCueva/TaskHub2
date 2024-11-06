<?php
header(header: 'Content-Type: application/json');


$conn = new mysqli('localhost', 'root', '', 'taskhub');


if ($conn->connect_error) {
    die(json_encode(['error' => 'Conexión fallida: ' . $conn->connect_error]));
}
$sql = "
    SELECT 
        subtarea.titulo, 
        subtarea.descripcion, 
        subtarea.tiempoEstimado, 
        subtarea.avance, 
        planificacion.fechaInicio 
    FROM subtarea
    JOIN planificacion ON subtarea.planificacion = planificacion.codigo
";


$result = $conn->query($sql);


$subtareas = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $subtareas[] = $row; 
    }
}

echo json_encode($subtareas);
$conn->close();
?>
