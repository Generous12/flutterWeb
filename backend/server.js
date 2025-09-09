require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// ------------------------ CONEXIÓN MYSQL ------------------------
let connection;

try {
  connection = mysql.createPool(process.env.MYSQL_URL);
  connection.getConnection((err, conn) => {
    if (err) {
      console.error("❌ Error conectando a MySQL:", err.message);
    } else {
      console.log("✅ Conexión a MySQL establecida");
      conn.release();
    }
  });
} catch (err) {
  console.error("❌ Error inicializando la conexión:", err.message);
}

// ------------------------ TIPOS DE COMPONENTE ------------------------
app.get('/tipo-componentes', (req, res) => {
  connection.query('CALL sp_list_tipo_componentes()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.post('/tipo-componente', (req, res) => {
  const { nombre } = req.body;
  connection.query('CALL sp_insert_tipo_componente(?)', [nombre], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results[0][0].id });
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

// ------------------------ COMPONENTES ------------------------
app.get('/componentes', (req, res) => {
  connection.query('SELECT * FROM Componente', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.post('/componente', (req, res) => {
  const { id_tipo, codigo_inventario, cantidad } = req.body;
  connection.query('CALL sp_upsert_componente(?, ?, ?, @out_id, @out_accion)', [id_tipo, codigo_inventario, cantidad], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0][0]);
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

// ------------------------ VALORES DE ATRIBUTO ------------------------
app.post('/valor-atributo', (req, res) => {
  const { id_componente, id_atributo, valor } = req.body;
  connection.query('CALL sp_upsert_valor_atributo(?, ?, ?, @out_id, @out_accion)', [id_componente, id_atributo, valor], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0][0]);
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

// ------------------------ ÁREAS ------------------------
app.get('/areas', (req, res) => {
  connection.query('CALL sp_list_areas()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

app.post('/area', (req, res) => {
  const { nombre_area } = req.body;
  connection.query('CALL sp_insert_area(?)', [nombre_area], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results[0][0].id });
  });
});

// ------------------------ CASES ------------------------
app.post('/assign-case', (req, res) => {
  const { id_componente_case, id_area, fecha_asignacion } = req.body;
  connection.query('CALL sp_add_component_to_case(?, ?, ?, @out_id)', [id_componente_case, id_area, fecha_asignacion], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0][0]);
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

// ------------------------ PUERTO ------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`Servidor corriendo en puerto ${PORT}`));
