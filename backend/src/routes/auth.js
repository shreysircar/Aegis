import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { pool } from "../db.js";


const router = express.Router();
// Temporary in-memory blacklist
const tokenBlacklist = new Set();

// Signup
router.post("/signup", async (req, res) => {
  const { fullname, email, password } = req.body;
  try {
    const hash = await bcrypt.hash(password, 10);
    await pool.query(
      "INSERT INTO users (fullname, email, password) VALUES ($1, $2, $3)",
      [fullname, email, hash]
    );
    res.json({ message: "User created" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await pool.query("SELECT * FROM users WHERE email=$1", [email]);
    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ id: user.id, email: user.email, fullname: user.fullname }, process.env.JWT_SECRET);
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get current user
router.get("/me", (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(" ")[1];
  if (!token) return res.status(401).json({ error: "No token" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    res.json(decoded);
  } catch {
    res.status(401).json({ error: "Invalid token" });
  }
});

// -------------------- SIGNOUT --------------------
router.post("/signout", (req, res) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader?.split(" ")[1];

    if (!token) {
      return res.status(401).json({ error: "No token provided" });
    }

    console.log("Signout request with token:", token);

    tokenBlacklist.add(token); // now works ✅
    res.json({ message: "Signed out successfully ✅" });

  } catch (err) {
    console.error("Error in /signout:", err.stack);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

export default router;
