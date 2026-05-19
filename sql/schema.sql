-- Schema for SecureShop
-- USERS table
CREATE TABLE users (
  id INT IDENTITY(1,1) PRIMARY KEY,
  username NVARCHAR(100) UNIQUE NOT NULL,
  email NVARCHAR(255) UNIQUE NOT NULL,
  password_hash NVARCHAR(255) NOT NULL,
  name NVARCHAR(200),
  role NVARCHAR(50) NOT NULL DEFAULT 'Customer',
  created_at DATETIME DEFAULT GETDATE()
);

-- PRODUCTS table
CREATE TABLE products (
  id INT IDENTITY(1,1) PRIMARY KEY,
  product_name NVARCHAR(255) NOT NULL,
  description NVARCHAR(MAX),
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT GETDATE()
);

-- ORDERS table
CREATE TABLE orders (
  id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT NOT NULL,
  order_date DATETIME DEFAULT GETDATE(),
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ORDER_ITEMS table
CREATE TABLE order_items (
  id INT IDENTITY(1,1) PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- PAYMENTS table
CREATE TABLE payments (
  id INT IDENTITY(1,1) PRIMARY KEY,
  order_id INT NOT NULL,
  payment_method NVARCHAR(50) NOT NULL,
  payment_status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
  payment_date DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- AUDIT_LOGS table
CREATE TABLE audit_logs (
  id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT NULL,
  action NVARCHAR(500),
  created_at DATETIME DEFAULT GETDATE(),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
