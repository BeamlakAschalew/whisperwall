import { Request, Response } from "express";
import { userSchema } from "./signup_validation";
import { connection } from "../database";
import { logger } from "./logger";
import { ResponseInstance, Status } from "../models/response";

export const signupUser = (req: Request, res: Response) => {
  const validateUseInfo = () => {
    console.log(process.env.DATABASE_NAME);

    return new Promise((resolve, reject) => {
      let error = userSchema.validate(req.body);

      if (error.error) {
        logger.error(`[${new Date().toISOString()}] ${error.error}`);
        reject(
          new ResponseInstance(
            new Status("2001"),
            error.error.details[0].message
          )
        );
      } else {
        resolve(req.body);
      }
    });
  };

  validateUseInfo()
    .then((body) => insertIntoDB(body))
    .then((data) => res.send(data))
    .catch((error) => res.send(error));
};

const insertIntoDB = (req: any): Promise<any> => {
  return new Promise((resolve, reject) => {
    connection.getConnection((error, connection) => {
      if (error) {
        reject(
          new ResponseInstance(
            new Status("2002"),
            `${error.name} ${error.message}`
          )
        );
        logger.error(`[${new Date().toISOString()}] ${error}`);
      } else {
        connection.query(
          `INSERT INTO whisperers (full_name, username, email, gender, dob, bio, password) VALUES (?, ?, ?, ?, ?, ?, (SELECT SHA2(?, 256)))`,
          [
            req.full_name,
            req.username,
            req.email,
            req.gender,
            req.dob,
            req.bio,
            req.password,
          ],
          (error, result, fields) => {
            if (error) {
              logger.error(`[${new Date().toISOString()}] ${error}`);
              reject(
                new ResponseInstance(
                  new Status("2003"),
                  `${error.name} ${error.message}`
                )
              );
            } else {
              resolve(result);
            }
          }
        );
      }
    });
  });
};
