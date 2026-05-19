# SecureShop

> Simple e-commerce management app (boilerplate)

## Structure

- `client/` — React frontend
- `server/` — Express backend
- `sql/` — schema and seed scripts

## Quick start

1. Copy `.env.example` to `.env` and fill values.
  - If your SQL Server is a named instance, set `DB_INSTANCE` to that instance name, or set `DB_HOST` to `host\\instance`.
2. Install server deps: `cd server && npm install`
3. Seed sample data and the admin account: `npm run seed` (from `server`)
4. Start server: `npm run dev` (from `server`)
5. Install client deps: `cd ../client && npm install`
6. Start client: `npm start`

Default seeded admin login:

- Email: `admin@example.com`
- Password: `Admin123!`

---

# SecureShop ERD Implementation Summary

## Database Schema

### 1. **USERS Table**
**New Fields Added:**
- `username` (NVARCHAR(100), UNIQUE) - Required for login/registration
- `password_hash` (renamed from `password`) - Stores bcrypt hashed passwords

**Schema:**
```sql
id (PK), username, email, password_hash, name, role, created_at
```

### 2. **PRODUCTS Table**
**Fields Updated:**
- `product_name` (renamed from `name`)
- `stock_quantity` (renamed from `stock`)
- `created_at` (added) - Track when product was created

**Schema:**
```sql
id (PK), product_name, description, price, stock_quantity, created_at
```

### 3. **ORDERS Table**
**New Fields Added:**
- `order_date` (DATETIME) - When order was placed
- `total_amount` (DECIMAL) - Total order value
- `status` (NVARCHAR(50)) - Order status (Pending, Confirmed, Shipped, Delivered, Cancelled)

**Schema:**
```sql
id (PK), user_id (FK), order_date, total_amount, status, created_at
```

### 4. **ORDER_ITEMS Table**
**New Fields Added:**
- `subtotal` (DECIMAL) - Item line subtotal (price × quantity)

**Schema:**
```sql
id (PK), order_id (FK), product_id (FK), quantity, subtotal
```

### 5. **PAYMENTS Table** ✨ NEW
**New Complete Table:**
- Tracks all payment transactions
- Links orders to payment records
- Stores payment method and status

**Schema:**
```sql
id (PK), order_id (FK), payment_method, payment_status, payment_date
```

---

## API Routes Updated

### Authentication Routes (`/api/auth`)
**Changes:**
- Register now requires: `username`, `email`, `password`, `name`
- Login uses `email` and `password` (hashed as `password_hash`)

**Updated Endpoints:**
```
POST /api/auth/register
POST /api/auth/login
```

### Products Routes (`/api/products`)
**Field Name Updates:**
- `name` → `product_name`
- `stock` → `stock_quantity`
- Added `created_at` to responses

**Endpoints:**
```
GET    /api/products              - List all products
GET    /api/products/:id          - Get single product
POST   /api/products              - Create product (Admin)
PUT    /api/products/:id          - Update product (Admin)
DELETE /api/products/:id          - Delete product (Admin)
```

### Orders Routes (`/api/orders`)
**Improvements:**
- Automatically calculates `total_amount` from items
- Sets initial `status` to "Pending"
- Stores `subtotal` for each order item
- Uses `order_date` instead of `created_at`

**Enhanced Endpoints:**
```
POST   /api/orders                - Create order (with total calculation)
GET    /api/orders/me             - Get user's orders
GET    /api/orders                - Get all orders (Admin)
GET    /api/orders/:id            - Get order details
```

### Payments Routes (`/api/payments`) ✨ NEW
**New API Endpoints:**
```
POST   /api/payments                    - Create payment for order
GET    /api/payments/order/:orderId    - Get payments for specific order
PATCH  /api/payments/:paymentId        - Update payment status (Admin)
GET    /api/payments                    - Get all payments (Admin)
```

---

## Server Code Changes

### Files Modified:
1. **`server/index.js`** - Added payments route
2. **`server/routes/auth.js`** - Updated for username + password_hash
3. **`server/routes/orders.js`** - Total amount calculation, subtotal tracking
4. **`server/routes/products.js`** - Updated field names
5. **`server/routes/payments.js`** ✨ NEW - Complete payment management

---

## Implementation Checklist

- [x] Database schema updated
- [x] All tables created with relationships
- [x] Auth routes updated (username, password_hash)
- [x] Orders routes enhanced (total_amount, status, subtotal)
- [x] Products routes updated (field names)
- [x] Payments routes created
- [x] Transaction handling for orders

## Next Steps

1. **Apply Database Schema**
   ```sql
   -- Run sql/schema.sql in your SQL Server database
   ```

2. **Seed Sample Data**
   ```sql
   -- Run sql/seed.sql to add test products
   ```

3. **Test API Endpoints**
   - Register with username + email
   - Login with email
   - Create products as Admin
   - Create orders with automatic total calculation
   - Create and track payments

4. **Update Client Code**
   - Update registration form to include username field
   - Change field references: `name` → `product_name`, `stock` → `stock_quantity`
   - Use new payment endpoints for checkout flow

5. **Environment Configuration**
   - Ensure `.env` has all required variables
   - JWT_SECRET for token generation
   - Database connection details

---

## Field Mapping Reference

| Purpose | Old Field | New Field |
|---------|-----------|-----------|
| Products Name | `name` | `product_name` |
| Products Stock | `stock` | `stock_quantity` |
| User Password | `password` | `password_hash` |
| Users Display Name | N/A | `username` (new) |
| Order Total | N/A | `total_amount` (new) |
| Order Status | N/A | `status` (new) |
| Item Total | N/A | `subtotal` (new) |
| Payments | N/A | `payments` table (new) |

---

## API Request/Response Examples

### Create Order (POST /api/orders)
```json
Request Body:
{
  "items": [
    { "productId": 1, "quantity": 2 },
    { "productId": 3, "quantity": 1 }
  ]
}

Response:
{
  "orderId": 10,
  "totalAmount": 1369.97,
  "status": "Pending"
}
```

### Create Payment (POST /api/payments)
```json
Request Body:
{
  "orderId": 10,
  "paymentMethod": "credit_card"
}

Response:
{
  "payment": {
    "id": 5,
    "order_id": 10,
    "payment_method": "credit_card",
    "payment_status": "Pending",
    "payment_date": "2024-05-19T12:34:56.000Z"
  }
}
```

---

## Notes
- All timestamps use SQL Server's GETDATE() function
- Foreign key constraints ensure data integrity
- Transactions ensure order + order items are atomic
- Subtotals are calculated at order creation time
- Total amounts automatically sum all items
