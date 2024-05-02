import express, { Router } from "express";
import { signupUser } from "../middleware/users/signup";
import { loginUser } from "../middleware/users/login";

const router: Router = express.Router();

router.post("/signup", signupUser);
router.post("/login", loginUser);

export const userRouter: Router = router;
