const express = require('express');
const router = express.Router();
const connection = require('../db');

router.get('/', (req, res) => {
  connection.query('CALL sp_list_areas()', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results[0]);
  });
});

router.post('/', (req, res) => {
  const { nombre_area } = req.body;
  connection.query('CALL sp_insert_area(?)', [nombre_area], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: results[0][0].id });
  });
});

module.exports = router;
