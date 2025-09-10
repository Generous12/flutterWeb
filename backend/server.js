require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Rutas
app.use('/tipo-componentes', require('./routes/tipoComponente'));
app.use('/componentes', require('./routes/componente'));
app.use('/valores', require('./routes/valorAtributo'));
app.use('/areas', require('./routes/area'));
app.use('/cases', require('./routes/cases'));

// Puerto
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () =>
  console.log(`Servidor corriendo en puerto ${PORT}`)
);
