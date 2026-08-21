const Express = require("express");
const cors = require('cors')
require("dotenv").config();

const App = Express();
App.use(cors());      
App.use(Express.json());

const ServerRouter = require("./src/Routers/Server.Routes")
App.use("/api", ServerRouter);

const PORT = process.env.PORT || 5000;

App.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
})