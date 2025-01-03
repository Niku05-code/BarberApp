const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const corsOptions = {
  origin: '*', // Permite toate sursele
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors(corsOptions));
app.use(bodyParser.json());
function authenticateToken(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Access denied' });

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
}

// Conexiune MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'NiCuLcES2580',
  database: process.env.DB_NAME || 'BarberAppSQL',
});

// Conectarea la baza de date
db.connect((err) => {
  if (err) {
    console.error('Eroare la conectarea la baza de date:', err);
  } else {
    console.log('Conectat la baza de date MySQL.');
  }
});

app.post('/register', async (req, res) => {
  const { firstName, lastName, email, password } = req.body;

  console.log('Date primite:', req.body);

  try {
    // Combinăm numele și prenumele
    const fullName = `${firstName} ${lastName}`;

    // Criptăm parola
    const hashedPassword = await bcrypt.hash(password, 10);

    // Interogare SQL pentru inserare
    const sql = 'INSERT INTO users (name, email, password) VALUES (?, ?, ?)';
    db.query(sql, [fullName, email, hashedPassword], (err, result) => {
      if (err) {
        console.error('Eroare SQL:', err);
        return res.status(500).json({ error: 'Eroare la înregistrare.' });
      }
      res.status(201).json({ message: 'Utilizator înregistrat cu succes.' });
    });
  } catch (err) {
    console.error('Eroare server:', err);
    res.status(500).json({ error: 'Eroare de server.' });
  }
});

app.post('/login', (req, res) => {
  const { email, password } = req.body;

  const sql = 'SELECT * FROM users WHERE email = ?';
  db.query(sql, [email], async (err, results) => {
    if (err || results.length === 0) {
      return res.status(401).json({ error: 'Email sau parolă incorectă.' });
    }

    const user = results[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Email sau parolă incorectă.' });
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
      expiresIn: '1h',
    });
    res.json({ message: 'Autentificare reușită.', token });
  });
});



// Start server
app.listen(PORT, () => {
  console.log(`Server pornit pe portul ${PORT}.`);
});
