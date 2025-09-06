// server.js
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors()); // Permite peticiones desde Flutter Web en otro dominio

// ------------------------------
// Conexión a Railway
// ------------------------------
const connection = mysql.createPool({
  host: 'switchback.proxy.rlwy.net',
  port: 40357,
  user: 'root',
  password: 'kqpBGGnsxhIrKmyUFLwFYTTKdhFnQVhr',
  database: 'railway',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// ------------------------------
// ENDPOINTS: TIPO_COMPONENTE
// ------------------------------
app.get('/tipo-componentes', (req, res) => {
  connection.query('CALL sp_list_tipo_componentes()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.post('/tipo-componente', (req, res) => {
  const { nombre } = req.body;
  connection.query('CALL sp_insert_tipo_componente(?, @out_id); SELECT @out_id AS id;', [nombre], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results[1][0].id });
  });
});

app.put('/tipo-componente/:id', (req, res) => {
  const { id } = req.params;
  const { nombre } = req.body;
  connection.query('CALL sp_update_tipo_componente(?, ?)', [id, nombre], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Tipo componente actualizado' });
  });
});

app.delete('/tipo-componente/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_delete_tipo_componente(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Tipo componente eliminado' });
  });
});

// ------------------------------
// ENDPOINTS: COMPONENTE
// ------------------------------
app.get('/componentes', (req, res) => {
  connection.query('SELECT * FROM Componente', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/componente', (req, res) => {
  const { id_tipo, codigo_inventario, cantidad } = req.body;
  const sql = 'CALL sp_upsert_componente(?, ?, ?, @out_id, @out_accion); SELECT @out_id AS id, @out_accion AS accion;';
  connection.query(sql, [id_tipo, codigo_inventario, cantidad], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[1][0]);
  });
});

app.put('/componente/:id', (req, res) => {
  const { id } = req.params;
  const { cantidad } = req.body;
  connection.query('CALL sp_set_cantidad_componente(?, ?)', [id, cantidad], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Cantidad actualizada' });
  });
});

app.delete('/componente/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_delete_componente(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Componente eliminado' });
  });
});

app.get('/componente/:id/atributos', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_get_componente_con_atributos(?)', [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// ------------------------------
// ENDPOINTS: VALOR_ATRIBUTO
// ------------------------------
app.post('/valor-atributo', (req, res) => {
  const { id_componente, id_atributo, valor } = req.body;
  const sql = 'CALL sp_upsert_valor_atributo(?, ?, ?, @out_id, @out_accion); SELECT @out_id AS id, @out_accion AS accion;';
  connection.query(sql, [id_componente, id_atributo, valor], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[1][0]);
  });
});

app.get('/valores/:id_componente', (req, res) => {
  const { id_componente } = req.params;
  connection.query('CALL sp_get_valores_por_componente(?)', [id_componente], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.delete('/valor-atributo/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_delete_valor_atributo(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Valor eliminado' });
  });
});

// ------------------------------
// ENDPOINTS: AREA y CASE
// ------------------------------
app.get('/areas', (req, res) => {
  connection.query('CALL sp_list_areas()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.post('/area', (req, res) => {
  const { nombre_area } = req.body;
  connection.query('CALL sp_insert_area(?, @out_id); SELECT @out_id AS id;', [nombre_area], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results[1][0].id });
  });
});

app.post('/assign-case', (req, res) => {
  const { id_componente_case, id_area, fecha_asignacion } = req.body;
  connection.query('CALL sp_add_component_to_case(?, ?, 1, ?, @out_id); SELECT @out_id AS id;', [id_componente_case, id_area, fecha_asignacion], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[1][0]);
  });
});

app.delete('/remove-case/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_remove_component_from_case(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Componente removido del case' });
  });
});

app.get('/cases/:id_area', (req, res) => {
  const { id_area } = req.params;
  connection.query('CALL sp_list_cases_asignados_por_area(?)', [id_area], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

// ------------------------------
// START SERVER
// ------------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor corriendo en http://localhost:${PORT}`));
