import express, { Router } from "express";
import { postWhisper } from "../middleware/whispers/post_whisper";
import { getTopToday } from "../middleware/whisperers/get_top_today";

const whisperRouterR: Router = express.Router();
const whispersRouterR: Router = express.Router();

whisperRouterR.post("/post", postWhisper);
whispersRouterR.get("/top/today", getTopToday);

export const whisperRouter: Router = whisperRouterR,
  whispersRouter: Router = whispersRouterR;
