-- Seed sample data

-- Sample Products
INSERT INTO products (product_name, description, price, stock_quantity) VALUES
(N'Laptop', N'High-performance gaming laptop with 16GB RAM', 1299.99, 25),
(N'Wireless Mouse', N'Ergonomic wireless mouse with 2.4GHz connection', 29.99, 150),
(N'USB-C Cable', N'Fast charging USB-C cable 6ft long', 19.99, 200),
(N'Monitor Stand', N'Adjustable monitor stand for better ergonomics', 49.99, 75),
(N'Keyboard', N'Mechanical RGB keyboard with Cherry MX switches', 149.99, 50);

-- Note: Use the server seed script to create user accounts with bcrypt password hashes
-- Example insert (do not use unhashed passwords in production):
-- INSERT INTO users (username, email, password_hash, name, role) VALUES
-- (N'admin', N'admin@secureshop.com', N'<bcrypt_hash>', N'Administrator', 'Admin'),
-- (N'customer1', N'customer1@secureshop.com', N'<bcrypt_hash>', N'John Doe', 'Customer');
