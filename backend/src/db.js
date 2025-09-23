import pg from "pg";
import dotenv from "dotenv";

dotenv.config();

export const pool = new pg.Pool({
  user: "neondb_owner",
  password: "npg_ntxo3U7bDuHm",
  host: "ep-plain-lab-adgdswk6-pooler.c-2.us-east-1.aws.neon.tech",
  database: "neondb",
  port: 5432,
  ssl: { rejectUnauthorized: false } // required for Neon
});

// Test connection
pool.connect()
  .then(client => {
    console.log("Connected to NeonDB successfully ✅");
    client.release();
  })
  .catch(err => {
    console.error("Failed to connect to NeonDB ❌", err.message);
  });

// Named export: function to initialize database
export async function initdb() {
  try {
    console.log("Initializing database...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        fullname VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log("Database initialized.");
  } catch (error) {
    console.error("Error initializing database:", error);
  }
}
