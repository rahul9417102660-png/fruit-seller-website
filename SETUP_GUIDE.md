# 🚀 Fruit Seller Website - Setup Guide

## Prerequisites
- Node.js (v14+)
- npm or yarn
- MongoDB (local या MongoDB Atlas)
- Git

## Step 1: MongoDB Setup

### Option A: Local MongoDB
```bash
# Windows/Mac/Linux में MongoDB install करें
# फिर mongod command से server start करें
mongod
```

### Option B: MongoDB Atlas (Cloud)
1. https://www.mongodb.com/cloud/atlas पर जाएं
2. Account बनाएं
3. Cluster create करें
4. Connection string copy करें
5. `.env` में paste करें

## Step 2: Backend Setup

```bash
# Backend folder में जाएं
cd backend

# Dependencies install करें
npm install

# .env file बनाएं (template: .env.example)
# Copy करें: .env.example को .env
cp .env.example .env

# Edit करें .env file:
MONGODB_URI=mongodb://localhost:27017/fruit-seller
PORT=5000
JWT_SECRET=your_secret_key_123
ADMIN_JWT_SECRET=admin_secret_key_456
NODE_ENV=development
```

### Backend Server Start करें:
```bash
npm start
# या development mode के लिए:
npm run dev
```

✅ Server चलना चाहिए http://localhost:5000 पर

## Step 3: Frontend Setup

```bash
# Frontend folder में जाएं
cd frontend

# Dependencies install करें
npm install

# Start करें
npm start
```

✅ Website खुलेगी http://localhost:3000 पर

## Step 4: Admin Panel Setup

```bash
# Admin panel folder में जाएं
cd admin-panel

# Dependencies install करें
npm install

# Start करें
npm start
```

✅ Admin panel खुलेगा http://localhost:3001 पर

## API Endpoints

### Products
- `GET /api/products` - सभी products
- `POST /api/products` - नया product add करें
- `PUT /api/products/:id` - Product edit करें
- `DELETE /api/products/:id` - Product delete करें

### Orders
- `GET /api/orders` - सभी orders
- `POST /api/orders` - नया order
- `PUT /api/orders/:id/status` - Order status update करें

### Auth
- `POST /api/auth/register` - User register
- `POST /api/auth/login` - User login
- `POST /api/auth/admin-login` - Admin login

## Database Schema

### Product
```javascript
{
  name: String,
  description: String,
  price: Number,
  weight: Number,
  weightUnit: String,
  category: String,
  image: String,
  video: String,
  stock: Number,
  rating: Number,
  reviews: Array,
  active: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Order
```javascript
{
  orderNumber: String,
  customer: {
    name: String,
    email: String,
    phone: String,
    address: String,
    city: String,
    state: String,
    pincode: String
  },
  items: Array,
  totalAmount: Number,
  quantity: Number,
  status: String,
  paymentMethod: String,
  paymentStatus: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Features

### 🛍️ Customer Website
- ✅ Home page with featured products
- ✅ Browse & search products
- ✅ Product details page
- ✅ Shopping cart
- ✅ Checkout
- ✅ Order tracking
- ✅ Product reviews

### 👨‍💼 Admin Panel
- ✅ Dashboard with statistics
- ✅ Product management
- ✅ Image upload
- ✅ Order management
- ✅ Customer details
- ✅ Delivery tracking
- ✅ Revenue analytics
- ✅ Order status management

## Common Issues & Solutions

### Issue: MongoDB Connection Error
**Solution:** 
```bash
# MongoDB चल रहा है या नहीं check करें
# Windows: Task Manager में mongod देखें
# Mac/Linux: ps aux | grep mongod

# या MongoDB Atlas connection string use करें
```

### Issue: Port 5000 already in use
**Solution:**
```bash
# Different port use करें या existing process kill करें
# .env में PORT=5001 करें
```

### Issue: CORS Error
**Solution:**
```bash
# backend में .env में सही origin add करें
# या frontend से axios में baseURL check करें
```

## Production Deployment

### Deploy करने के लिए तैयार करें:
```bash
# Frontend build करें
cd frontend
npm run build

# Admin build करें
cd admin-panel
npm run build

# Backend तैयार करें
# Production .env file बनाएं
```

## Support
किसी भी समस्या के लिए GitHub issues create करें या contact करें।

---
**Happy Coding! 🚀**
