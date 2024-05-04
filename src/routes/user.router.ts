import express, { Router } from "express";
import { signupUser } from "../middleware/whisperers/signup";
import { loginUser } from "../middleware/whisperers/login";

const router: Router = express.Router();

router.post("/signup", signupUser);
router.post("/login", loginUser);

export const userRouter: Router = router;
