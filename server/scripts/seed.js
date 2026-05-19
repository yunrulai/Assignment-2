require('dotenv').config();
const bcrypt = require('bcrypt');
const { getPool } = require('../db/db');

async function main() {
  const pool = await getPool();
  const passwordHash = await bcrypt.hash('Admin123!', 10);

  try {
    // Create admin user with new schema
    await pool.request()
      .input('username', 'admin')
      .input('email', 'admin@example.com')
      .input('password_hash', passwordHash)
      .input('name', 'Administrator')
      .query(`
        IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@example.com')
        BEGIN
          INSERT INTO users (username, email, password_hash, name, role)
          VALUES (@username, @email, @password_hash, @name, 'Admin');
          PRINT 'Admin user created';
        END
        ELSE
        BEGIN
          PRINT 'Admin user already exists';
        END
      `);

    // Create sample products with new schema
    const products = [
      { name: 'Laptop', description: 'High-performance gaming laptop with 16GB RAM', price: 1299.99, stock: 25 },
      { name: 'Wireless Mouse', description: 'Ergonomic wireless mouse with 2.4GHz connection', price: 29.99, stock: 150 },
      { name: 'USB-C Cable', description: 'Fast charging USB-C cable 6ft long', price: 19.99, stock: 200 },
      { name: 'Monitor Stand', description: 'Adjustable monitor stand for better ergonomics', price: 49.99, stock: 75 },
      { name: 'Keyboard', description: 'Mechanical RGB keyboard with Cherry MX switches', price: 149.99, stock: 50 }
    ];

    for (const product of products) {
      await pool.request()
        .input('product_name', product.name)
        .input('description', product.description)
        .input('price', product.price)
        .input('stock_quantity', product.stock)
        .query(`
          IF NOT EXISTS (SELECT 1 FROM products WHERE product_name = @product_name)
          BEGIN
            INSERT INTO products (product_name, description, price, stock_quantity)
            VALUES (@product_name, @description, @price, @stock_quantity);
            PRINT 'Product created: ' + @product_name;
          END
          ELSE
          BEGIN
            PRINT 'Product already exists: ' + @product_name;
          END
        `);
    }

    console.log('\n✅ Seed completed successfully!');
    console.log('\nDefault Admin Account:');
    console.log('  Email: admin@example.com');
    console.log('  Password: Admin123!');
    console.log('  Role: Admin');
  } catch (err) {
    console.error('❌ Seed error:', err);
  } finally {
    process.exit(0);
  }
}

main();