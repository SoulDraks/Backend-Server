const { pool } = require("../Database/db");

const ESTADOS = ["disponible", "prestado", "reparacion"];
const TIPOS = ["entrega", "devolucion", "traspaso", "reparacion", "alta"];

const texto = (valor, largo) =>
  valor === null || valor === undefined ? "" : String(valor).trim().slice(0, largo);

function exigir(valor, largo, campo) {
  const t = texto(valor, largo);
  if (!t) {
    const error = new Error(`Falta el campo ${campo}`);
    error.status = 400;
    throw error;
  }
  return t;
}

const unaLista = datos => (Array.isArray(datos) ? datos : [datos]);

function aFechaSql(iso) {
  const d = iso ? new Date(iso) : new Date();
  return (isNaN(d) ? new Date() : d).toISOString().slice(0, 19).replace("T", " ");
}

function aIso(valor) {
  if(valor instanceof Date)
    return valor.toISOString();
  return new Date(`${valor}Z`).toISOString();
}

function filaEquipo(e) {
  const codigo = exigir(e.codigo, 64, "codigo").toUpperCase();
  const estado = texto(e.estado, 16) || "disponible";
  if (!ESTADOS.includes(estado)) {
    const error = new Error(`Estado desconocido: ${estado}`);
    error.status = 400;
    throw error;
  }
  return [
    codigo,
    texto(e.numero, 64) || codigo,
    exigir(e.modelo, 32, "modelo"),
    estado,
    texto(e.reserva, 120),
    texto(e.falla, 120),
    texto(e.notas, 2000),
    e.prestamo ? JSON.stringify(e.prestamo) : null,
    aFechaSql(e.actualizado)
  ];
}

function filaMovimiento(m) {
  const tipo = exigir(m.tipo, 16, "tipo");
  if (!TIPOS.includes(tipo)) {
    const error = new Error(`Tipo de movimiento desconocido: ${tipo}`);
    error.status = 400;
    throw error;
  }
  return [
    exigir(m.id, 32, "id"),
    tipo,
    exigir(m.codigo, 64, "codigo").toUpperCase(),
    texto(m.profesor, 120),
    texto(m.curso, 60),
    texto(m.detalle, 200),
    aFechaSql(m.fecha)
  ];
}

// Funcion auxiliar para poder manejar Errores que generan los Endpoints
function manejar(manejador) {
  return (req, res) => Promise.resolve(manejador(req, res)).catch(error => {
    console.error(error);
    res.status(error.status || 500).json({ error: error.message || "Error interno" });
  });
}

async function Estado(_req, res) {
  const [modelos] = await pool.query("SELECT * FROM modelos ORDER BY nombre");
  const [equipos] = await pool.query("SELECT * FROM equipos ORDER BY codigo");
  const [movimientos] = await pool.query("SELECT * FROM movimientos ORDER BY fecha DESC LIMIT 500");

  res.json({
    modelos,
    equipos: equipos.map(e => ({
      ...e,
      prestamo: typeof e.prestamo === "string" ? JSON.parse(e.prestamo) : e.prestamo,
      actualizado: aIso(e.actualizado)
    })),
    movimientos: movimientos.map(m => ({ ...m, fecha: aIso(m.fecha) }))
  });
}

async function Modelos(_req, res) {
  const [rows] = await pool.query("SELECT * FROM modelos ORDER BY nombre");
  res.json(rows);
}

async function Equipos(_req, res) {
  const [rows] = await pool.query(`
    SELECT e.*, m.nombre AS modelo_nombre
    FROM equipos e
    JOIN modelos m ON m.clave = e.modelo
    ORDER BY e.codigo
  `);
  res.json(rows.map(e => ({
    ...e,
    prestamo: typeof e.prestamo === "string" ? JSON.parse(e.prestamo) : e.prestamo,
    actualizado: aIso(e.actualizado)
  })));
}

async function Pendientes(_req, res) {
  const [rows] = await pool.query("SELECT * FROM pendientes ORDER BY salida_utc ASC");
  res.json(rows.map(row => ({ ...row, salida_utc: row.salida_utc ? aIso(row.salida_utc) : null })));
}

async function GuardarEquipos(req, res) {
  const filas = unaLista(req.body).map(filaEquipo);
  if (filas.length) {
    await pool.query(`
      INSERT INTO equipos (codigo, numero, modelo, estado, reserva, falla, notas, prestamo, actualizado)
      VALUES ?
      ON DUPLICATE KEY UPDATE
        numero = VALUES(numero),
        modelo = VALUES(modelo),
        estado = VALUES(estado),
        reserva = VALUES(reserva),
        falla = VALUES(falla),
        notas = VALUES(notas),
        prestamo = VALUES(prestamo),
        actualizado = VALUES(actualizado)
    `, [filas]);
  }
  res.json({ ok: true, guardados: filas.length });
}

async function GuardarMovimientos(req, res) {
  const filas = unaLista(req.body).map(filaMovimiento);
  if (filas.length) {
    await pool.query(
      "INSERT IGNORE INTO movimientos (id, tipo, codigo, profesor, curso, detalle, fecha) VALUES ?",
      [filas]
    );
  }
  res.json({ ok: true, guardados: filas.length });
}

async function Borrar(req, res) {
  const { equipo, movimiento } = req.body || {};
  if (equipo) {
    await pool.query("DELETE FROM equipos WHERE codigo = ?", [texto(equipo, 64).toUpperCase()]);
  } else if (movimiento) {
    await pool.query("DELETE FROM movimientos WHERE id = ?", [texto(movimiento, 32)]);
  } else {
    const error = new Error('Hay que mandar "equipo" o "movimiento"');
    error.status = 400;
    throw error;
  }
  res.json({ ok: true });
}

async function BuscarPorCodigo(req, res) {
  const codigo = normalizarCodigo(req.params.codigo);
  if (!codigo) return res.status(400).json({ error: "Falta el código de barras" });

  const [rows] = await pool.query(`
    SELECT e.*, m.nombre AS modelo_nombre, m.hostname, m.ram, m.cpu,
           m.almacenamiento, m.gpu, m.so
    FROM equipos e
    JOIN modelos m ON m.clave = e.modelo
    WHERE e.codigo = ? OR e.numero = ?
    LIMIT 1
  `, [codigo, codigo]);

  if (!rows.length) return res.status(404).json({ error: "Equipo no encontrado", codigo });

  return res.json({ ok: true, equipo: parsearEquipo(rows[0]) });
}

module.exports = {
  Estado: manejar(Estado),
  Modelos: manejar(Modelos),
  Equipos: manejar(Equipos),
  Pendientes: manejar(Pendientes),
  GuardarEquipos: manejar(GuardarEquipos),
  GuardarMovimientos: manejar(GuardarMovimientos),
  Borrar: manejar(Borrar),
  BuscarPorCodigo: manejar(BuscarPorCodigo)
};