import Joi from "joi";

export const userSchema = Joi.object({
  full_name: Joi.string().min(4).max(60).required(),
  password: Joi.string().min(8).required(),
  email: Joi.string().required(),
  username: Joi.string().min(5).max(30).required(),
  bio: Joi.string().max(150),
  dob: Joi.string(),
  gender: Joi.string().min(1).max(1).required(),
});
