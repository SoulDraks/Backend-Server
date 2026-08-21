const express = require("express");
const ServerRouter = express.Router();
const {Prueba} = require("../Controller/Server.Controller");

ServerRouter.get("/prueba/", Prueba);

module.exports = ServerRouter;