// backend/db.js

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

const setupDatabase = async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Create schema if it doesn't exist
    await client.query('CREATE SCHEMA IF NOT EXISTS labcom');

    // Create table if it doesn't exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS labcom.labcom_data (
        id SERIAL PRIMARY KEY,
        value INTEGER,
        description TEXT
      )
    `);

    // Check if table is empty
    const res = await client.query('SELECT * FROM labcom.labcom_data LIMIT 1');
    if (res.rows.length === 0) {
      // Insert initial entry if table is empty
      await client.query(`
        INSERT INTO labcom.labcom_data (value, description)
        VALUES (1337, 'Hi Yuri')
      `);
    }

    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

module.exports = {
  pool,
  setupDatabase,
};

