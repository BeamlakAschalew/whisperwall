import { Request } from "express";
import { ResponseInstance, Status } from "../../models/response";
import JWT from "jsonwebtoken";

export const checkToken = (req: Request) => {
  return new Promise((resolve, reject) => {
    const token = req.header("auth-token");
    if (token) {
      resolve(token);
    } else {
      reject(new ResponseInstance(new Status("4003"), "provide token"));
    }
  });
};

export const tokenAuth = (token: any, req: Request) => {
  return new Promise((resolve, reject) => {
    const verification = JWT.verify(token, "WHISPERWALL") as any;
    if (req.header("auth-username") == undefined) {
      reject(
        new ResponseInstance(
          new Status("4004"),
          "provide username in auth header"
        )
      );
    }

    const isVerified =
      req.header("auth-username") !== verification.username ? false : true;

    if (isVerified) {
      resolve(req);
    } else {
      reject(
        new ResponseInstance(
          new Status("4005"),
          "unauthenticated user, use valid token"
        )
      );
    }
  });
};
