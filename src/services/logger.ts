import winston, { createLogger, format, transports } from "winston";

const log = createLogger({
  transports: [
    new transports.Console(), // Log to console
  ],
  format: format.combine(
    format.timestamp(),
    format.json() // Log in JSON format
  ),
});

export const logger: winston.Logger = log;
