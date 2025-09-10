const express = require('express');
const router = express.Router();
const connection = require('../db');

router.post('/assign', (req, res) => {
  const { id_componente_case, id_area, fecha_asignacion } = req.body;
  connection.query(
    'CALL sp_add_component_to_case(?, ?, ?, @out_id)',
    [id_componente_case, id_area, fecha_asignacion],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results[0][0]);
    }
  );
});

router.delete('/remove/:id', (req, res) => {
  const { id } = req.params;
  connection.query('CALL sp_remove_component_from_case(?)', [id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Componente removido del case' });
  });
});

router.get('/:id_area', (req, res) => {
  const { id_area } = req.params;
  connection.query('CALL sp_list_cases_asignados_por_area(?)', [id_area], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

module.exports = router;
