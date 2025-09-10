const express = require('express');
const router = express.Router();
const connection = require('../db');

router.post('/', (req, res) => {
  const { id_componente, id_atributo, valor } = req.body;
  connection.query(
    'CALL sp_upsert_valor_atributo(?, ?, ?, @out_id, @out_accion)',
    [id_componente, id_atributo, valor],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results[0][0]);
    }
  );
});

router.get('/:id_componente', (req, res) => {
  const { id_componente } = req.params;
  connection.query('CALL sp_get_valores_por_componente(?)', [id_componente], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

router.delete('/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_delete_valor_atributo(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Valor eliminado' });
  });
});

module.exports = router;
