import Joi from "joi";

export const whisperSchema = Joi.object({
  whisperer_id: Joi.number().required(),
  primary_wall_id: Joi.number().required(),
  whisper_content: Joi.string().required(),
  walls: Joi.array(),
});
