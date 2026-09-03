const Express = require("express");
const cors = require("cors");
require("dotenv").config();

const { prepararBD, config } = require("./src/Database/db");
const ServerRouter = require("./src/Routers/Server.Routes");

const App = Express();
App.use(cors());
App.use(Express.json({ limit: "1mb" }));
App.use("/api", ServerRouter);

const PORT = Number(process.env.PORT || 5000);

async function iniciar() {
  try {
    await prepararBD();
    App.listen(PORT, () => {
      console.log(`Servidor corriendo en http://localhost:${PORT}`);
      console.log(`MySQL: ${config.user}@${config.host}:${config.port}/${config.database}`);
    });
  } catch (error) {
    console.error("No se pudo preparar la base MySQL:", error.message);
    console.error("Revisá que MySQL/MariaDB esté iniciado y que .env tenga credenciales válidas.");
    process.exit(1);
  }
}

iniciar();
