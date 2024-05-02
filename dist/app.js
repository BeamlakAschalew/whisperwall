"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const dotenv_1 = __importDefault(require("dotenv"));
const logger_1 = require("./src/services/logger");
const user_router_1 = require("./src/routes/user.router");
dotenv_1.default.config();
const app = (0, express_1.default)();
const port = process.env.PORT || 8000;
app.use(express_1.default.json());
app.use((req, res, next) => {
    logger_1.logger.info(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});
app.get("/", (req, res) => {
    res.send("Welcome to Express & TypeScript Server");
});
app.use("/user", user_router_1.userRouter);
app.use((err, req, res, next) => {
    logger_1.logger.error(`[${new Date().toISOString()}] ${err.stack}`);
    res.status(500).send("Something went wrong.");
});
app.listen(port, () => {
    console.log(`Server is running at port ${port}`);
});
