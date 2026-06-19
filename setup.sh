#!/bin/bash

# Fruit Seller Website - Complete Setup Script
# This script sets up the entire project with backend, frontend, and admin panel

echo "================================"
echo "🍎 Fruit Seller Website Setup"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js found: $(node -v)${NC}"
echo -e "${GREEN}✅ npm found: $(npm -v)${NC}"
echo ""

# Create project structure
echo -e "${YELLOW}📁 Creating project structure...${NC}"

mkdir -p backend/{config,models,routes,uploads/products,middleware}
mkdir -p frontend/{src/{components,pages},public}
mkdir -p admin-panel/{src/{components,pages},public}

echo -e "${GREEN}✅ Project structure created${NC}"
echo ""

# Backend setup
echo -e "${YELLOW}📦 Setting up Backend...${NC}"
cd backend

# Create package.json
cat > package.json << 'EOF'
{
  "name": "fruit-seller-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.0.0",
    "dotenv": "^16.0.3",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.0",
    "multer": "^1.4.5-lts.1",
    "cors": "^2.8.5"
  }
}
EOF

# Create .env
cat > .env << 'EOF'
MONGODB_URI=mongodb://localhost:27017/fruit-seller
PORT=5000
JWT_SECRET=fruit_seller_secret_key_2024
JWT_EXPIRE=7d
ADMIN_JWT_SECRET=admin_secret_key_2024
NODE_ENV=development
EOF

# Create config/db.js
cat > config/db.js << 'EOF'
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    return conn;
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
EOF

# Create models/Product.js
cat > models/Product.js << 'EOF'
const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, required: true },
    price: { type: Number, required: true },
    weight: { type: Number, required: true },
    weightUnit: { type: String, default: 'kg', enum: ['kg', 'g', 'pieces'] },
    category: { type: String, required: true, enum: ['Fruits', 'Vegetables', 'Organic', 'Premium'] },
    image: { type: String, required: true },
    video: { type: String, default: null },
    stock: { type: Number, required: true, default: 0 },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    reviews: [
      {
        user: String,
        rating: Number,
        comment: String,
        date: { type: Date, default: Date.now },
      },
    ],
    active: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Product', ProductSchema);
EOF

# Create models/Order.js
cat > models/Order.js << 'EOF'
const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema(
  {
    orderNumber: { type: String, unique: true, required: true },
    customer: {
      name: String,
      email: String,
      phone: String,
      address: String,
      city: String,
      state: String,
      pincode: String,
    },
    items: [
      {
        productId: mongoose.Schema.Types.ObjectId,
        productName: String,
        quantity: Number,
        weight: Number,
        price: Number,
        totalPrice: Number,
      },
    ],
    totalAmount: { type: Number, required: true },
    quantity: { type: Number, required: true },
    status: {
      type: String,
      enum: ['Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'],
      default: 'Pending',
    },
    paymentMethod: { type: String, enum: ['COD', 'Online', 'UPI'], default: 'COD' },
    paymentStatus: { type: String, enum: ['Pending', 'Completed', 'Failed'], default: 'Pending' },
    deliveryDate: Date,
    trackingId: String,
    notes: String,
  },
  { timestamps: true }
);

OrderSchema.pre('save', async function (next) {
  if (!this.orderNumber) {
    const count = await this.constructor.countDocuments();
    this.orderNumber = `ORD-${Date.now()}-${count + 1}`;
  }
  next();
});

module.exports = mongoose.model('Order', OrderSchema);
EOF

# Create models/User.js
cat > models/User.js << 'EOF'
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    phone: { type: String, required: true },
    password: { type: String, required: true, minlength: 6, select: false },
    address: String,
    city: String,
    state: String,
    pincode: String,
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
  },
  { timestamps: true }
);

UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

UserSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
EOF

# Create routes/products.js
cat > routes/products.js << 'EOF'
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const Product = require('../models/Product');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads/products'));
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);
    if (mimetype && extname) return cb(null, true);
    cb('Error: Images only!');
  },
});

router.get('/', async (req, res) => {
  try {
    const products = await Product.find({ active: true });
    res.json({ success: true, count: products.length, data: products });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, error: 'Product not found' });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/', upload.single('image'), async (req, res) => {
  try {
    const { name, description, price, weight, weightUnit, category, stock } = req.body;
    if (!req.file) return res.status(400).json({ success: false, error: 'Image required' });

    const product = new Product({
      name,
      description,
      price,
      weight,
      weightUnit,
      category,
      stock,
      image: `/uploads/products/${req.file.filename}`,
    });

    await product.save();
    res.status(201).json({ success: true, message: 'Product added', data: product });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.put('/:id', upload.single('image'), async (req, res) => {
  try {
    let updateData = req.body;
    if (req.file) updateData.image = `/uploads/products/${req.file.filename}`;

    const product = await Product.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    });

    if (!product) return res.status(404).json({ success: false, error: 'Product not found' });
    res.json({ success: true, message: 'Product updated', data: product });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, { active: false }, { new: true });
    if (!product) return res.status(404).json({ success: false, error: 'Product not found' });
    res.json({ success: true, message: 'Product deleted', data: product });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
EOF

# Create routes/orders.js
cat > routes/orders.js << 'EOF'
const express = require('express');
const router = express.Router();
const Order = require('../models/Order');

router.get('/', async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, error: 'Order not found' });
    res.json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { customer, items, totalAmount, quantity, paymentMethod } = req.body;
    if (!items || items.length === 0) return res.status(400).json({ success: false, error: 'Items required' });

    const order = new Order({ customer, items, totalAmount, quantity, paymentMethod });
    await order.save();
    res.status(201).json({ success: true, message: 'Order created', data: order });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status, deliveryDate: status === 'Delivered' ? new Date() : null },
      { new: true, runValidators: true }
    );
    if (!order) return res.status(404).json({ success: false, error: 'Order not found' });
    res.json({ success: true, message: 'Order updated', data: order });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.get('/stats/dashboard', async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    const totalRevenue = await Order.aggregate([{ $group: { _id: null, total: { $sum: '$totalAmount' } } }]);
    const pendingOrders = await Order.countDocuments({ status: 'Pending' });
    const deliveredOrders = await Order.countDocuments({ status: 'Delivered' });

    res.json({
      success: true,
      data: {
        totalOrders,
        totalRevenue: totalRevenue[0]?.total || 0,
        pendingOrders,
        deliveredOrders,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
EOF

# Create routes/auth.js
cat > routes/auth.js << 'EOF'
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRE });
};

router.post('/register', async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ success: false, error: 'User already exists' });

    user = new User({ name, email, phone, password });
    await user.save();

    const token = generateToken(user._id);
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      token,
      user: { id: user._id, name: user.name, email: user.email, phone: user.phone },
    });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ success: false, error: 'Please provide email and password' });

    const user = await User.findOne({ email }).select('+password');
    if (!user) return res.status(401).json({ success: false, error: 'Invalid credentials' });

    const isMatch = await user.matchPassword(password);
    if (!isMatch) return res.status(401).json({ success: false, error: 'Invalid credentials' });

    const token = generateToken(user._id);
    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: { id: user._id, name: user.name, email: user.email, phone: user.phone, role: user.role },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/admin-login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email, role: 'admin' }).select('+password');
    if (!user) return res.status(401).json({ success: false, error: 'Invalid admin credentials' });

    const isMatch = await user.matchPassword(password);
    if (!isMatch) return res.status(401).json({ success: false, error: 'Invalid admin credentials' });

    const token = jwt.sign({ id: user._id }, process.env.ADMIN_JWT_SECRET, { expiresIn: process.env.JWT_EXPIRE });
    res.json({
      success: true,
      message: 'Admin login successful',
      token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
EOF

# Create server.js
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('./config/db');

dotenv.config();
connectDB();

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const authRoutes = require('./routes/auth');

app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/auth', authRoutes);

app.get('/api/health', (req, res) => {
  res.json({ message: 'Server is running ✅' });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Backend Server running on http://localhost:${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
});
EOF

cd ..
echo -e "${GREEN}✅ Backend files created${NC}"
echo ""

# Install Backend Dependencies
echo -e "${YELLOW}📥 Installing backend dependencies...${NC}"
cd backend
npm install > /dev/null 2>&1
cd ..
echo -e "${GREEN}✅ Backend dependencies installed${NC}"
echo ""

echo ""
echo -e "${GREEN}================================"
echo "✅ SETUP COMPLETE!"
echo "================================${NC}"
echo ""
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo ""
echo "1. ${YELLOW}START MONGODB:${NC}"
echo "   - On Windows: Start MongoDB service or run 'mongod'"
echo "   - On Mac: brew services start mongodb-community"
echo "   - On Linux: sudo systemctl start mongod"
echo ""
echo "2. ${YELLOW}START BACKEND:${NC}"
echo "   cd backend && npm start"
echo "   Backend will run on: http://localhost:5000"
echo ""
echo "3. ${YELLOW}START FRONTEND:${NC}"
echo "   cd frontend && npm install && npm start"
echo "   Website will run on: http://localhost:3000"
echo ""
echo "4. ${YELLOW}START ADMIN PANEL:${NC}"
echo "   cd admin-panel && npm install && npm start"
echo "   Admin will run on: http://localhost:3001"
echo ""
echo -e "${GREEN}Admin Credentials:${NC}"
echo "Email: admin@example.com"
echo "Password: admin123"
echo ""
echo -e "${GREEN}================================"
echo "🍎 Happy Coding!"
echo "================================${NC}"
