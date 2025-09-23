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
