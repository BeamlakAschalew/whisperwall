import { Request, Response } from "express";
import { whisperSchema } from "../../services/whisper_validation";
import { logger } from "../../services/logger";
import { ResponseInstance, Status } from "../../models/response";
import { database } from "../../database";

const postWhisper = (req: Request, res: Response) => {
  validateWhisper(req)
    .then((data) => insertWhisper(data))
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
          [body.primary_wall_id, body.whisper_id, body.whisper_content],
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
              const r = result as any;
              console.log(`DB RESPONSE ${r}`);

              resolve(r);
            }
          }
        );
      }
    });
  });
};

export const generateWhisperWallQuery = (body: any) => {
  let wallIds: number[] = body.walls;
  let query = `INSERT INTO whisper_walls (whisper_id, wall_id) VALUES (${body.whisper_id}, ${body.primary_wall_id})`;

  if (wallIds.length > 1) {
    for (let i = 1; i < wallIds.length; i++) {
      query += `, (${body.whisper_id}, ${wallIds[i]})`;
    }
  }

  console.log(query);

  return new Promise((resolve, reject) => {});
};
