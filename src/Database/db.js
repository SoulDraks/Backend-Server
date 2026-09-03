const mysql = require("mysql2/promise");
require("dotenv").config();

const config = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3000,
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "serverdesk",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: "Z"
};

const pool = mysql.createPool(config);

async function prepararBD() {
  const fs = require("node:fs");
  const path = require("node:path");
  const sqlPath = path.join(__dirname, "..", "..", "sql", "serverdesk.sql");
  const sql = fs.readFileSync(sqlPath, "utf8");

  const bootstrap = await mysql.createConnection({
    host: config.host,
    port: config.port,
    user: config.user,
    password: config.password,
    timezone: "Z",
    multipleStatements: true
  });

  try {
    await bootstrap.query(sql);
  } finally {
    await bootstrap.end();
  }
}

module.exports = { pool, prepararBD, config };
