import mysql from "mysql2";
import dotenv from "dotenv";

dotenv.config();

const pool: mysql.PoolOptions = {
  user: process.env.DATABASE_USERNAME,
  database: process.env.DATABASE_NAME,
  password: process.env.DATABASE_PASSWORD,
  waitForConnections: true,
  connectionLimit: 0,
  maxIdle: 10,
  idleTimeout: 60000,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
};

export const connection: mysql.Pool = mysql.createPool(pool);
