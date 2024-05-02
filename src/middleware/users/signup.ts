import { Request, Response } from "express";
import { userSignupSchema } from "../../services/signup_validation";
import { database } from "../../database";
import { logger } from "../../services/logger";
import { ResponseInstance, Status } from "../../models/response";
import bcrypt from "bcryptjs";

export const signupUser = (req: Request, res: Response) => {
  const validateUserInfo = () => {
    return new Promise((resolve, reject) => {
      let error = userSignupSchema.validate(req.body);

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

  validateUserInfo()
    .then((body) => encryptPassword(body).then((data) => insertIntoDB(body)))
    .then((data) => res.send(data))
    .catch((error) => res.send(error));
};

const encryptPassword = (req: any): Promise<any> => {
  return new Promise(async (resolve, reject) => {
    bcrypt.genSalt(10, (error, salt) => {
      if (error) {
        logger.error(`[${new Date().toISOString()}] ${error}`);
        reject(
          new ResponseInstance(
            new Status("3007"),
            `${error.name} ${error.message}`
          )
        );
      }
      bcrypt.hash(req.password, salt, (error, result) => {
        if (error) {
          logger.error(`[${new Date().toISOString()}] ${error}`);
          reject(
            new ResponseInstance(
              new Status("3008"),
              `${error.name} ${error.message}`
            )
          );
        } else if (result) {
          req.password = result;
          resolve(req);
        }
      });
    });
  });
};

const insertIntoDB = (req: any): Promise<any> => {
  return new Promise((resolve, reject) => {
    database.getConnection((error, connection) => {
      if (error) {
        logger.error(`[${new Date().toISOString()}] ${error}`);
        reject(
          new ResponseInstance(
            new Status("2002"),
            `${error.name} ${error.message}`
          )
        );
      } else {
        connection.query(
          `CALL SignupUser(?, ?, ?, ?, ?, ?, ?)`,
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
            connection.release();
            if (error) {
              logger.error(`[${new Date().toISOString()}] ${error}`);
              reject(
                new ResponseInstance(
                  new Status("2003"),
                  `${error.name} ${error.message}`
                )
              );
            } else {
              const r = result as any;
              if (r[0][0].status === 3001) {
                logger.error(`[${new Date().toISOString()}] ${error}`);
                reject(
                  new ResponseInstance(
                    new Status("3001"),
                    `pick a different username`
                  )
                );
              } else if (r[0][0].status === 1001) {
                resolve(
                  new ResponseInstance(
                    new Status("3006"),
                    `signed up successfully`
                  )
                );
              }
            }
          }
        );
      }
    });
  });
};
