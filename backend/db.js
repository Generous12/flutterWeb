const mysql = require('mysql2');

const pool = mysql.createPool({
  host: process.env.MYSQLHOST,
  user: process.env.MYSQLUSER,
  password: process.env.MYSQLPASSWORD,
  database: process.env.MYSQLDATABASE,
  port: process.env.MYSQLPORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Verificar conexión al iniciar
pool.getConnection((err, conn) => {
  if (err) {
    console.error("❌ Error conectando a MySQL:", err.message);
  } else {
    console.log("✅ Conexión a MySQL establecida");
    conn.release();
  }
});

module.exports = pool;
