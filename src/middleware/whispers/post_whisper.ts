import { Request, Response } from "express";
import { whisperSchema } from "../../services/whisper_validation";
import { logger } from "../../services/logger";
import { ResponseInstance, Status } from "../../models/response";
import { database } from "../../database";

export const postWhisper = (req: Request, res: Response) => {
  validateWhisper(req.body)
    .then((data) =>
      insertWhisper(data).then((data) =>
        generateWhisperWallQuery(data).then((data) => res.send(data))
      )
    )
    .catch((error) => res.send(error));
};

const validateWhisper = (body: any) => {
  return new Promise((resolve, reject) => {
    let error = whisperSchema.validate(body);

    if (error.error) {
      logger.error(`[${new Date().toISOString()}] ${error.error}`);
      reject(
        new ResponseInstance(new Status("2001"), error.error.details[0].message)
      );
    } else {
      resolve(body);
    }
  });
};

const insertWhisper = (body: any) => {
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
        let query = `CALL InsertWhisper(?, ?, ?)`;
        connection.query(
          query,
          [body.primary_wall_id, body.whisperer_id, body.whisper_content],
          (error, result, fields) => {
            connection.release();
            if (error) {
              logger.error(`[${new Date().toISOString()}] ${error.errno}`);
              reject(
                new ResponseInstance(
                  new Status("2003"),
                  `${error.name} ${error.message}`
                )
              );
            } else {
              const r = result as any;

              if (r[0][0].whisper_status !== 1) {
                reject(new ResponseInstance(new Status("4002"), ""));
              } else {
                body.dbResponse = r[0][0];
                resolve(body);
              }
            }
          }
        );
      }
    });
  });
};

export const generateWhisperWallQuery = (body: any) => {
  let wallIds: number[] = body.walls !== undefined ? body.walls : [];
  let insertQuery = `INSERT INTO whisper_walls (whisper_id, wall_id) VALUES (${body.dbResponse.last_inserted_id}, ${body.primary_wall_id})`;

  if (wallIds.length > 1) {
    for (let i = 1; i < wallIds.length; i++) {
      insertQuery += `, (${body.dbResponse.last_inserted_id}, ${wallIds[i]})`;
    }
  }

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
        let query = `CALL InsertWhisperWall(?)`;
        connection.query(query, insertQuery, (error, result, fields) => {
          connection.release();
          if (error) {
            logger.error(`[${new Date().toISOString()}] ${error.errno}`);
            reject(
              new ResponseInstance(
                new Status("2003"),
                `${error.name} ${error.message}`
              )
            );
          } else {
            const r = result as any;

            if (r[0][0].whisper_wall_status !== 1) {
              reject(new ResponseInstance(new Status("4002"), ""));
            } else {
              resolve(
                new ResponseInstance(new Status("4001"), `post successful`)
              );
            }
          }
        });
      }
    });
  });
};
