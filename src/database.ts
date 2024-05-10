import mysql from "mysql2";
import dotenv from "dotenv";

dotenv.config();

const pool: mysql.PoolOptions = {
  host: process.env.DATABASE_HOST,
  port: Number.parseInt(process.env.DATABASE_PORT ?? "3306"),
  user: process.env.DATABASE_USERNAME,
  database: process.env.DATABASE_NAME,
  password: process.env.DATABASE_PASSWORD,
  localAddress: process.env.DATABASE_REQUEST_IP,
  waitForConnections: true,
  connectionLimit: 0,
  maxIdle: 10,
  idleTimeout: 60000,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
};

export const database: mysql.Pool = mysql.createPool(pool);
