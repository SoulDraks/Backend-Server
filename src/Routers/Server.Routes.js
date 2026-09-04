const express = require("express");
const ServerRouter = express.Router();
const {
  Estado,
  Modelos,
  Equipos,
  Pendientes,
  GuardarEquipos,
  GuardarMovimientos,
  Borrar,
  BuscarPorCodigo
} = require("../Controller/Server.Controller");
const {
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
} = require("../Controller/Auth.Controller");

// ── Rutas públicas (auth) ──
ServerRouter.post("/auth/registro", Registro);
ServerRouter.post("/auth/login", Login);
ServerRouter.post("/auth/logout", Logout);

// ── Rutas admin ──
ServerRouter.get("/auth/pendientes", Autenticar, ExigirAdmin, ListarPendientes);
ServerRouter.get("/auth/usuarios", Autenticar, ExigirAdmin, listarUsuarios);
ServerRouter.post("/auth/aprobar/:id", Autenticar, ExigirAdmin, AprobarUsuario);
ServerRouter.post("/auth/rechazar/:id", Autenticar, ExigirAdmin, RechazarUsuario);
ServerRouter.delete("/auth/usuarios/:id", Autenticar, ExigirAdmin, EliminarUsuario);

// ── Rutas protegidas (todas requieren login) ──
ServerRouter.get("/estado", Autenticar, Estado);
ServerRouter.get("/modelos", Autenticar, Modelos);
ServerRouter.get("/equipos", Autenticar, Equipos);
ServerRouter.get("/pendientes", Autenticar, Pendientes);
ServerRouter.post("/equipos", Autenticar, GuardarEquipos);
ServerRouter.post("/movimientos", Autenticar, GuardarMovimientos);
ServerRouter.get("/equipos/codigo/:codigo", Autenticar, BuscarPorCodigo);
ServerRouter.get("/barcode/:codigo", Autenticar, BuscarPorCodigo);
ServerRouter.post("/borrar", Autenticar, Borrar);

module.exports = ServerRouter;