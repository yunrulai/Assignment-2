const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { getPool } = require('../db/db');

// Register
router.post('/register', async (req, res) => {
  const { username, email, password, name } = req.body;
  const normalizedEmail = String(email || '').trim().toLowerCase();
  const trimmedUsername = String(username || '').trim();

  if (!trimmedUsername || !normalizedEmail || !password) {
    return res.status(400).json({ error: 'username, email and password required' });
  }

  try {
    const hash = await bcrypt.hash(password, 10);
    const pool = await getPool();
    
    // Check if email or username already exists
    const existing = await pool.request()
      .input('email', normalizedEmail)
      .input('username', trimmedUsername)
      .query('SELECT TOP 1 id FROM users WHERE email = @email OR username = @username');

    if (existing.recordset.length > 0) {
      return res.status(409).json({ error: 'email or username already exists' });
    }

    const result = await pool.request()
      .input('username', trimmedUsername)
      .input('email', normalizedEmail)
      .input('password_hash', hash)
      .input('name', name || trimmedUsername)
      .query("INSERT INTO users (username, email, password_hash, name, role) OUTPUT INSERTED.id, INSERTED.username, INSERTED.email, INSERTED.name, INSERTED.role VALUES (@username, @email, @password_hash, @name, 'Customer')");

    res.status(201).json({ user: result.recordset[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const normalizedEmail = String(email || '').trim().toLowerCase();

  if (!normalizedEmail || !password) {
    return res.status(400).json({ error: 'email and password required' });
  }

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('email', normalizedEmail)
      .query('SELECT TOP 1 id, username, email, password_hash, name, role FROM users WHERE email = @email');

    const user = result.recordset[0];
    if (!user) return res.status(401).json({ error: 'invalid credentials' });

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'invalid credentials' });

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'changeme', { expiresIn: '8h' });
    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name,
        role: user.role
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

module.exports = router;
