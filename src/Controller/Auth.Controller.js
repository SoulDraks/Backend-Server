const jwt = require("jsonwebtoken");
const { pool } = require("../Database/db");
const { EncriptarPassword, CompararPassword } = require("../Utils/Hash");

const JWT_SECRET = process.env.JWT_SECRET || "secreto_inseguro_cambiar";
const JWT_EXPIRES = "8h";

function firmarToken(usuario) {
  return jwt.sign(
    { id: usuario.id, email: usuario.email, rol: usuario.rol },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES }
  );
}

async function Registro(req, res) {
  const { nombre, email, password, invite_code } = req.body || {};

  if (!nombre || !email || !password) {
    return res.status(400).json({ error: "Faltan campos: nombre, email, password" });
  }

  const CodigoInvitacion = process.env.INVITE_CODE;
  if (CodigoInvitacion && invite_code !== CodigoInvitacion) {
    return res.status(403).json({ error: "Código de invitación inválido. No puedes registrarte sin él." });
  }

  const [existente] = await pool.query("SELECT id FROM usuarios WHERE email = ?", [email]);
  if (existente.length) {
    return res.status(409).json({ error: "El email ya está registrado" });
  }

  const hash = await EncriptarPassword(password);
  const [resultado] = await pool.query(
    "INSERT INTO usuarios (nombre, email, password, rol, aprobado) VALUES (?, ?, ?, 'operador', 0)",
    [nombre, email, hash]
  );

  res.status(201).json({
    ok: true,
    mensaje: "Registro exitoso. Tu cuenta está pendiente de aprobación por un administrador.",
    usuario: { id: resultado.insertId, nombre, email, rol: "operador", aprobado: false }
  });
}

async function Login(req, res) {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ error: "Faltan campos: email, password" });
  }

  const [filas] = await pool.query("SELECT * FROM usuarios WHERE email = ? LIMIT 1", [email]);
  if (!filas.length) {
    return res.status(401).json({ error: "Credenciales incorrectas" });
  }

  const usuario = filas[0];

  const coincide = await CompararPassword(password, usuario.password);
  if (!coincide) {
    return res.status(401).json({ error: "Credenciales incorrectas" });
  }

  if (!usuario.aprobado) {
    return res.status(403).json({ error: "Tu cuenta aún no fue aprobada por un administrador." });
  }

  const token = firmarToken(usuario);

  res.json({
    ok: true,
    token,
    usuario: { id: usuario.id, nombre: usuario.nombre, email: usuario.email, rol: usuario.rol }
  });
}

async function Logout(req, res) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.json({ ok: true });

  const token = authHeader.replace("Bearer ", "");
  try {
    const decodificado = jwt.decode(token);
    if (decodificado && decodificado.exp) {
      const expiradoEn = new Date(decodificado.exp * 1000);
      await pool.query(
        "INSERT IGNORE INTO tokens_invalidados (token, expirado_en) VALUES (?, ?)",
        [token, expiradoEn]
      );
    }
  } catch (_) {}

  res.json({ ok: true, mensaje: "Sesión cerrada" });
}

async function ListarPendientes(_req, res) {
  const [filas] = await pool.query(
    "SELECT id, nombre, email, rol, aprobado, created_at FROM usuarios WHERE aprobado = 0 ORDER BY created_at ASC"
  );
  res.json(filas);
}

async function AprobarUsuario(req, res) {
  const { id } = req.params;
  const [resultado] = await pool.query("UPDATE usuarios SET aprobado = 1 WHERE id = ? AND aprobado = 0", [id]);

  if (resultado.affectedRows === 0) {
    return res.status(404).json({ error: "Usuario no encontrado o ya aprobado" });
  }

  res.json({ ok: true, mensaje: `Usuario ${id} aprobado` });
}

async function RechazarUsuario(req, res) {
  const { id } = req.params;
  const [resultado] = await pool.query("DELETE FROM usuarios WHERE id = ? AND aprobado = 0", [id]);

  if (resultado.affectedRows === 0) {
    return res.status(404).json({ error: "Usuario no encontrado o ya procesado" });
  }

  res.json({ ok: true, mensaje: `Usuario ${id} eliminado` });
}

async function EliminarUsuario(req, res) {
  const { id } = req.params;

  if (Number(id) === req.usuario.id) {
    return res.status(400).json({ error: "No podés eliminarte a vos mismo" });
  }

  const [resultado] = await pool.query("DELETE FROM usuarios WHERE id = ?", [id]);
  if (resultado.affectedRows === 0) {
    return res.status(404).json({ error: "Usuario no encontrado" });
  }

  res.json({ ok: true, mensaje: `Usuario ${id} eliminado` });
}

async function listarUsuarios(_req, res) {
  const [filas] = await pool.query(
    "SELECT id, nombre, email, rol, aprobado, created_at FROM usuarios ORDER BY created_at DESC"
  );
  res.json(filas);
}

// ── Middleware de autenticación ──

function Autenticar(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Token de autenticación requerido" });
  }

  const token = authHeader.replace("Bearer ", "");

  jwt.verify(token, JWT_SECRET, async (err, decodificado) => {
    if (err) {
      return res.status(401).json({ error: "Token inválido o expirado" });
    }

    const [invalidado] = await pool.query(
      "SELECT 1 FROM tokens_invalidados WHERE token = ?", [token]
    );
    if (invalidado.length) {
      return res.status(401).json({ error: "Token revocado (sesión cerrada)" });
    }

    req.usuario = decodificado;
    next();
  });
}

function ExigirAdmin(req, res, next) {
  if (req.usuario.rol !== "admin") {
    return res.status(403).json({ error: "Se requieren permisos de administrador" });
  }
  next();
}

module.exports = {
  Registro,
  Login,
  Logout,
  ListarPendientes,
  AprobarUsuario,
  RechazarUsuario,
  EliminarUsuario,
  listarUsuarios,
  Autenticar,
  ExigirAdmin
};
