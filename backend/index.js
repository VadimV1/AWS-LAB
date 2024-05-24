// backend/index.js

const express = require('express');
const cors = require('cors'); // Importing CORS
const { pool, setupDatabase } = require('./db');
require('dotenv').config();

const app = express();
const port = process.env.PORT;
app.use(cors()); // Enabling CORS for all origins
app.use(express.json());

setupDatabase()
  .then(() => {
    console.log('Database setup complete');
  })
  .catch((err) => {
    console.error('Error setting up database:', err);
    process.exit(1);
  });

app.get('/data', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM labcom.labcom_data LIMIT 1');
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No data found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(port, () => {
  console.log(`Backend service listening at port :${port}`);
});

