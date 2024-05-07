import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
import { logger } from "./src/services/logger";
import { userRouter } from "./src/routes/user.router";
import { whisperRouter, whispersRouter } from "./src/routes/whisper.router";

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 8000;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

app.get("/", (req: Request, res: Response) => {
  res.send("WHATCHU LOOKIN AT NIGGA");
});

app.use("/user", userRouter);
app.use("/whispers", whispersRouter);
app.use("/whisper", whisperRouter);

app.use((err: any, req: Request, res: Response, next: any) => {
  logger.error(`[${new Date().toISOString()}] ${err.stack}`);
  res.status(500).send("Something went wrong.");
});

app.listen(port, () => {
  console.log(`Server is running at port ${port}`);
});
