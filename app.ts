import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
import { logger } from "./src/services/logger";
import { userRouter } from "./src/routes/user.router";
import { generateWhisperWallQuery } from "./src/middleware/whispers/post_whisper";

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 8000;

app.use(express.json());

app.use((req, res, next) => {
  logger.info(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

app.get("/", (req: Request, res: Response) => {
  res.send("Welcome to Express & TypeScript Server");
  generateWhisperWallQuery({
    walls: [1, 2, 3, 4],
    primary_wall_id: 7,
    whisper_id: 56,
  });
});

app.use("/user", userRouter);

app.use((err: any, req: Request, res: Response, next: any) => {
  logger.error(`[${new Date().toISOString()}] ${err.stack}`);
  res.status(500).send("Something went wrong.");
});

app.listen(port, () => {
  console.log(`Server is running at port ${port}`);
});
