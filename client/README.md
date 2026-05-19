# SecureShop — Client (Frontend)

A modern React-based e-commerce frontend for SecureShop with authentication, product browsing, shopping cart, and admin panel.

## Features

**User Authentication**
- Registration with username, email, password
- Login with email/password
- JWT token-based session management

**Product Browsing**
- View all available products with descriptions
- Real-time stock status
- Easy add to cart functionality

**Shopping Cart**
- Add/remove items
- Adjust quantities
- Multiple payment methods support
- Order total calculation

**Order Management**
- View order history
- Track order status (Pending, Confirmed, Shipped, Delivered)
- Detailed order items with subtotals

**Admin Panel** (for admin users)
- Add/delete products
- View all orders
- Manage payments and payment status

## Setup

### Prerequisites
- Node.js 14+ and npm installed
- Backend server running on `http://localhost:3001`

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm start
   ```

The app will open at `http://localhost:3000`

## Project Structure

```
src/
├── App.js                 # Main application component
├── App.css               # Global styling
├── api.js                # API client utility
├── index.js              # React entry point
└── pages/
    ├── Login.js          # User login page
    ├── Register.js       # User registration page
    ├── Products.js       # Product listing and browsing
    ├── Cart.js           # Shopping cart and checkout
    ├── Orders.js         # Order history
    └── AdminPanel.js     # Admin management dashboard
```

## Available Pages

### Login Page
- Email and password login
- Link to register page
- Displays errors from server

### Register Page
- Username, email, password, and full name
- Auto-login after successful registration
- Link back to login page

### Products Page
- Grid view of all products
- Product name, description, price
- Current stock quantity
- Add to Cart button (disabled if out of stock)

### Cart Page
- View all items in cart
- Adjust quantities with +/- buttons
- Remove items individually
- Clear entire cart
- Select payment method
- Checkout button that creates order and payment

### Orders Page
- View all past orders
- Order ID, date, status, and total
- Detailed list of items in each order
- Order status badges

### Admin Panel
Three tabs:
1. **Products Tab**
   - Form to add new products
   - List of all products with delete option

2. **Orders Tab**
   - Table of all customer orders
   - Order details and status

3. **Payments Tab**
   - All payment transactions
   - Update payment status (Pending, Completed, Failed)
   - Customer and order information

## Test Accounts

Default admin account (created via server seed):
```
Email: admin@example.com
Password: Admin123!
```

Or create a new account via the Register page.

## API Endpoints Used

The client communicates with these backend endpoints:

```
POST   /api/auth/register
POST   /api/auth/login
GET    /api/products
GET    /api/products/:id
POST   /api/products (Admin)
PUT    /api/products/:id (Admin)
DELETE /api/products/:id (Admin)
POST   /api/orders
GET    /api/orders/me
GET    /api/orders (Admin)
POST   /api/payments
GET    /api/payments/order/:orderId
GET    /api/payments (Admin)
PATCH  /api/payments/:paymentId (Admin)
```

## Styling

The application uses a modern gradient-based design with:
- Responsive grid layouts
- Mobile-friendly navigation
- Color-coded status indicators
- Smooth hover effects and animations
- Accessible form controls

## Common Issues

**"Network error" on login/register:**
- Ensure backend server is running on `http://localhost:3001`
- Check that all required environment variables are set on the server

**CORS errors:**
- Backend must have CORS enabled for `http://localhost:3000`
- Check server CORS configuration

**Products not loading:**
- Ensure database is seeded with products
- Check backend connection

## Build for Production

```bash
npm run build
```

This creates a production-ready build in the `build/` folder.
