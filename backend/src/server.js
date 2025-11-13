/* //mobile app(android emulator)
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./routes/auth.js";
import { initdb } from "./db.js"; // named import


dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);

// Initialize DB
initdb();

app.get("/", (req, res) => res.send("Aegis Backend Running ✅"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
console.log("JWT_SECRET:", process.env.JWT_SECRET);
*/

import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import authRoutes from "./routes/auth.js";
import { initdb } from "./db.js";

// Load .env explicitly (since your .env is in a different folder)
dotenv.config({ path: path.resolve('../path-to-env/.env') }); // <-- replace with actual relative path
console.log("JWT_SECRET:", process.env.JWT_SECRET);

const app = express();
app.use(cors({ origin: '*' })); // allow Flutter Web to call backend
app.use(express.json());
app.use("/api/auth", authRoutes);

// Initialize DB
initdb();

app.get("/", (req, res) => res.send("Aegis Backend Running ✅"));

const PORT = process.env.PORT || 4000;

// Listen on all interfaces so browser can reach it
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
