import { Request, Response } from "express";
import { database } from "../../database";
import { ResponseInstance, Status } from "../../models/response";
import { logger } from "../../services/logger";
import { WhisperResponse, Whisper } from "../../types";

export const getTopToday = (req: Request, res: Response) => {
  fetchData(req)
    .then((data) => formatResponse(data).then((data) => res.send(data)))
    .catch((error) => res.send(error));
};

const fetchData = (req: Request) => {
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
        const sql: string = "CALL GetTopToday(?)";
        const value = req.query.page ?? 1;

        connection.query(sql, value, (error, result, fields) => {
          connection.release();
          if (error) {
            logger.error(`[${new Date().toISOString()}] ${error}`);
            reject(
              new ResponseInstance(
                new Status("5001"),
                `${error.name} ${error.message}`
              )
            );
          } else {
            const r = result as any;
            resolve(r);
          }
        });
      }
    });
  });
};

const formatResponse = (data: any) => {
  const hasNext = data[0][0].has_next;
  const rawWhisper = data[1];
  const whispers: Whisper[] = [];

  rawWhisper.forEach((element: any) => {
    whispers.push(element);
  });

  const whisperResponse: WhisperResponse = {
    has_next: hasNext === 0 ? false : true,
    whispers: whispers,
  };

  return new Promise((resolve, reject) => {
    resolve(whisperResponse);
  });
};
