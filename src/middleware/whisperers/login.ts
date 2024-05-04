import { Request, Response } from "express";
import { userLoginSchema } from "../../services/login_validation";
import { logger } from "../../services/logger";
import { ResponseInstance, Status } from "../../models/response";
import { database } from "../../database";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export const loginUser = (req: Request, res: Response) => {
  validateUserInfo(req)
    .then((data) =>
      getUserByUsername(data).then((data) =>
        checkPassword(data).then((data) => finalizeLogin(data, res))
      )
    )
    .catch((error) => res.send(error));
};

const validateUserInfo = (req: Request) => {
  return new Promise((resolve, reject) => {
    let error = userLoginSchema.validate(req.body);

    if (error.error) {
      logger.error(`[${new Date().toISOString()}] ${error.error}`);
      reject(
        new ResponseInstance(new Status("2001"), error.error.details[0].message)
      );
    } else {
      resolve(req.body);
    }
  });
};

const getUserByUsername = (req: any): Promise<any> => {
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
        const sql: string = "CALL GetUserByUsername(?)";
        const value = req.username;

        connection.query(sql, value, (error, result, fields) => {
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
            req.databaseData = r[0][0];
            resolve(req);
          }
        });
      }
    });
  });
};

const checkPassword = (req: any): Promise<any> => {
  return new Promise((resolve, reject) => {
    bcrypt.compare(
      req.password,
      req.databaseData.password,
      (error, success) => {
        if (error) {
          logger.error(`[${new Date().toISOString()}] ${error}`);
          reject(
            new ResponseInstance(
              new Status("2004"),
              `${error.name} ${error.message}`
            )
          );
        } else {
          if (success) {
            delete req.username;
            delete req.password;
            req.loggedIn = true;
            resolve(req);
          } else {
            logger.error(`[${new Date().toISOString()}] ${error}`);
            reject(
              new ResponseInstance(new Status("3004"), `incorrect password`)
            );
          }
        }
      }
    );
  });
};

const finalizeLogin = (data: any, res: Response) => {
  const filteredData = {
    full_name: data.databaseData.full_name,
    username: data.databaseData.username,
    bio: data.databaseData.bio,
    dob: data.databaseData.dob,
    created_at: data.databaseData.created_at,
    email: data.databaseData.email,
    gender: data.databaseData.gender,
    status: data.databaseData.status,
  };

  const auth_token = jwt.sign(filteredData, "WHISPERWALL");

  delete data.databaseData.password;
  delete data.databaseData.id;

  res.setHeader("auth-token", auth_token);
  res.send(new ResponseInstance(new Status("3005"), `logged in`, filteredData));
};
