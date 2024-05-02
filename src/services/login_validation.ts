import Joi from "joi";

export const userLoginSchema = Joi.object({
  password: Joi.string().min(8).required(),
  username: Joi.string().min(5).max(30).required(),
});
