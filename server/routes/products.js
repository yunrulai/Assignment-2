const express = require('express');
const router = express.Router();
const { getPool } = require('../db/db');
const auth = require('../middleware/auth');
const requireRole = auth.requireRole;

// List products
router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT id, product_name, description, price, stock_quantity, created_at FROM products ORDER BY id DESC');
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Get a single product
router.get('/:id', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', req.params.id)
      .query('SELECT TOP 1 id, product_name, description, price, stock_quantity, created_at FROM products WHERE id = @id');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'product not found' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Create product
router.post('/', auth, requireRole('Admin'), async (req, res) => {
  const { product_name, description = '', price, stock_quantity = 0 } = req.body;

  if (!product_name || price === undefined) {
    return res.status(400).json({ error: 'product_name and price required' });
  }

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('product_name', product_name)
      .input('description', description)
      .input('price', price)
      .input('stock_quantity', stock_quantity)
      .query("INSERT INTO products (product_name, description, price, stock_quantity) OUTPUT INSERTED.id, INSERTED.product_name, INSERTED.description, INSERTED.price, INSERTED.stock_quantity, INSERTED.created_at VALUES (@product_name, @description, @price, @stock_quantity)");

    res.status(201).json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Update product
router.put('/:id', auth, requireRole('Admin'), async (req, res) => {
  const { product_name, description, price, stock_quantity } = req.body;
  const normalizedDescription = description === undefined ? null : description;
  const normalizedPrice = price === undefined ? null : price;
  const normalizedStockQuantity = stock_quantity === undefined ? null : stock_quantity;

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', req.params.id)
      .input('product_name', product_name)
      .input('description', normalizedDescription)
      .input('price', normalizedPrice)
      .input('stock_quantity', normalizedStockQuantity)
      .query(`
        UPDATE products
        SET
          product_name = COALESCE(@product_name, product_name),
          description = COALESCE(@description, description),
          price = COALESCE(@price, price),
          stock_quantity = COALESCE(@stock_quantity, stock_quantity)
        OUTPUT INSERTED.id, INSERTED.product_name, INSERTED.description, INSERTED.price, INSERTED.stock_quantity, INSERTED.created_at
        WHERE id = @id
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'product not found' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Delete product
router.delete('/:id', auth, requireRole('Admin'), async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', req.params.id)
      .query('DELETE FROM products OUTPUT DELETED.id WHERE id = @id');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'product not found' });
    }

    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

module.exports = router;
