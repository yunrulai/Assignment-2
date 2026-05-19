const express = require('express');
const router = express.Router();
const { getPool } = require('../db/db');
const auth = require('../middleware/auth');
const requireRole = auth.requireRole;

// Create payment for an order
router.post('/', auth, async (req, res) => {
  const { orderId, paymentMethod } = req.body;
  const userId = req.user.id;

  if (!orderId || !paymentMethod) {
    return res.status(400).json({ error: 'orderId and paymentMethod required' });
  }

  try {
    const pool = await getPool();

    // Verify the order belongs to the user or user is admin
    const orderCheck = await pool.request()
      .input('orderId', orderId)
      .query('SELECT TOP 1 id, user_id FROM orders WHERE id = @orderId');

    if (orderCheck.recordset.length === 0) {
      return res.status(404).json({ error: 'order not found' });
    }

    const order = orderCheck.recordset[0];
    if (order.user_id !== userId && req.user.role !== 'Admin') {
      return res.status(403).json({ error: 'forbidden' });
    }

    // Create payment record
    const result = await pool.request()
      .input('orderId', orderId)
      .input('paymentMethod', paymentMethod)
      .input('status', 'Pending')
      .query(`
        INSERT INTO payments (order_id, payment_method, payment_status) 
        OUTPUT INSERTED.id, INSERTED.order_id, INSERTED.payment_method, INSERTED.payment_status, INSERTED.payment_date
        VALUES (@orderId, @paymentMethod, @status)
      `);

    res.status(201).json({ payment: result.recordset[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Get payments for a specific order
router.get('/order/:orderId', auth, async (req, res) => {
  const { orderId } = req.params;
  const userId = req.user.id;

  try {
    const pool = await getPool();

    // Verify the order belongs to the user or user is admin
    const orderCheck = await pool.request()
      .input('orderId', orderId)
      .query('SELECT TOP 1 id, user_id FROM orders WHERE id = @orderId');

    if (orderCheck.recordset.length === 0) {
      return res.status(404).json({ error: 'order not found' });
    }

    const order = orderCheck.recordset[0];
    if (order.user_id !== userId && req.user.role !== 'Admin') {
      return res.status(403).json({ error: 'forbidden' });
    }

    // Get payments for the order
    const result = await pool.request()
      .input('orderId', orderId)
      .query(`
        SELECT id, order_id, payment_method, payment_status, payment_date
        FROM payments
        WHERE order_id = @orderId
        ORDER BY payment_date DESC
      `);

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Update payment status (Admin only)
router.patch('/:paymentId', auth, requireRole('Admin'), async (req, res) => {
  const { paymentId } = req.params;
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ error: 'status required' });
  }

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('paymentId', paymentId)
      .input('status', status)
      .query(`
        UPDATE payments
        SET payment_status = @status
        WHERE id = @paymentId
        
        SELECT id, order_id, payment_method, payment_status, payment_date
        FROM payments
        WHERE id = @paymentId
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'payment not found' });
    }

    res.json({ payment: result.recordset[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

// Get all payments (Admin only)
router.get('/', auth, requireRole('Admin'), async (req, res) => {
  try {
    const pool = await getPool();

    const result = await pool.request().query(`
      SELECT p.id, p.order_id, p.payment_method, p.payment_status, p.payment_date,
             o.user_id, u.name AS customer_name, o.total_amount, o.status AS order_status
      FROM payments p
      INNER JOIN orders o ON o.id = p.order_id
      INNER JOIN users u ON u.id = o.user_id
      ORDER BY p.payment_date DESC
    `);

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'server error' });
  }
});

module.exports = router;
