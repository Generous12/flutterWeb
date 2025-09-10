const express = require('express');
const router = express.Router();
const connection = require('../db');

router.get('/', (req, res) => {
  connection.query('SELECT * FROM Componente', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.post('/', (req, res) => {
  const { id_tipo, codigo_inventario, cantidad } = req.body;
  connection.query(
    'CALL sp_upsert_componente(?, ?, ?, @out_id, @out_accion)',
    [id_tipo, codigo_inventario, cantidad],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results[0][0]);
    }
  );
});

router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { cantidad } = req.body;
  connection.query('CALL sp_set_cantidad_componente(?, ?)', [id, cantidad], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Cantidad actualizada' });
  });
});

router.delete('/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_delete_componente(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Componente eliminado' });
  });
});

router.get('/:id/atributos', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_get_componente_con_atributos(?)', [id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

module.exports = router;
