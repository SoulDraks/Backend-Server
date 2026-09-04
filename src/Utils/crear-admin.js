/**
 * Script para crear el primer usuario admin.
 * Ejecutar: node src/Utils/crear-admin.js
 */
const mysql = require("mysql2/promise");
require("dotenv").config();
const { EncriptarPassword } = require("./Hash");

async function crearAdmin() {
  const email = process.argv[2] || "admin@serverdesk.com";
  const password = process.argv[3] || "admin123";
  const nombre = process.argv[4] || "Administrador";

  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASS || "",
    database: process.env.DB_NAME || "serverdesk",
    timezone: "Z"
  });

  try {
    const [existente] = await conn.query("SELECT id FROM usuarios WHERE email = ?", [email]);
    if (existente.length) {
      console.log(`Ya existe un usuario con el email: ${email}`);
      return;
    }

    const hash = await EncriptarPassword(password);
    await conn.query(
      "INSERT INTO usuarios (nombre, email, password, rol, aprobado) VALUES (?, ?, ?, 'admin', 1)",
      [nombre, email, hash]
    );
    console.log(`Admin creado: ${email} / ${password}`);
  } finally {
    await conn.end();
  }
}

crearAdmin().catch(err => {
  console.error("Error:", err.message);
  process.exit(1);
});
