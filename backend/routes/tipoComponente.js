const express = require('express');
const router = express.Router();
const connection = require('../db');

router.get('/', (req, res) => {
  connection.query('CALL sp_list_tipo_componentes()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

router.post('/', (req, res) => {
  const { nombre } = req.body;
  connection.query('CALL sp_insert_tipo_componente(?)', [nombre], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results[0][0].id });
  });
});

router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { nombre } = req.body;
  connection.query('CALL sp_update_tipo_componente(?, ?)', [id, nombre], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Tipo componente actualizado' });
  });
});

router.delete('/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_delete_tipo_componente(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Tipo componente eliminado' });
  });
});

module.exports = router;
