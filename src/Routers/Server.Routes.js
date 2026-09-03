const express = require("express");
const ServerRouter = express.Router();
const {
  Prueba,
  Estado,
  Modelos,
  Equipos,
  Pendientes,
  GuardarEquipos,
  GuardarMovimientos,
  Borrar,
  BuscarPorCodigo
} = require("../Controller/Server.Controller");

ServerRouter.get("/prueba/", Prueba);
ServerRouter.get("/estado", Estado);
ServerRouter.get("/modelos", Modelos);
ServerRouter.get("/equipos", Equipos);
ServerRouter.get("/pendientes", Pendientes);
ServerRouter.post("/equipos", GuardarEquipos);
ServerRouter.post("/movimientos", GuardarMovimientos);
ServerRouter.get("/equipos/codigo/:codigo", BuscarPorCodigo);
ServerRouter.get("/barcode/:codigo", BuscarPorCodigo);
ServerRouter.post("/borrar", Borrar);

module.exports = ServerRouter;