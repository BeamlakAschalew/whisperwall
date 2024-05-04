import express, { Router } from "express";
import { postWhisper } from "../middleware/whispers/post_whisper";

const router: Router = express.Router();

router.post("/post", postWhisper);

export const whisperRouter: Router = router;
