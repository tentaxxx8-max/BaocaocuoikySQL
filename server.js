const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
require('dotenv').config();

const { getPool } = require('./config/db');

const authRoutes = require('./routes/auth.routes');
const productRoutes = require('./routes/product.routes');
const cartRoutes = require('./routes/cart.routes');
const orderRoutes = require('./routes/order.routes');
const addressRoutes = require('./routes/address.routes');
const reviewRoutes = require('./routes/review.routes');
const couponRoutes = require('./routes/coupon.routes');
const bannerRoutes = require('./routes/banner.routes');
const storeRoutes = require('./routes/store.routes');
const tradeinRoutes = require('./routes/tradein.routes');
const installmentRoutes = require('./routes/installment.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser());

// Static Files
app.use(express.static(path.join(__dirname, 'public')));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api/banners', bannerRoutes);
app.use('/api/stores', storeRoutes);
app.use('/api/trade-in', tradeinRoutes);
app.use('/api/installments', installmentRoutes);
app.use('/api/admin', adminRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ONLINE',
    store: 'FARM OF PHAM',
    timestamp: new Date().toISOString()
  });
});

// API 404 Handler (match any unhandled /api path)
app.use('/api', (req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint không tồn tại.' });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('[Unhandled Error]:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Lỗi hệ thống nội bộ.',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Start server function
async function startServer() {
  try {
    await getPool();
    app.listen(PORT, () => {
      console.log(`====================================================`);
      console.log(`   [FARM OF PHAM] TACTICAL GAME VAULT SERVER READY! `);
      console.log(`   App running at: http://localhost:${PORT}`);
      console.log(`   Admin panel:    http://localhost:${PORT}/admin`);
      console.log(`====================================================`);
    });
  } catch (err) {
    console.error('CRITICAL: Cannot start server due to Database Connection Failure:', err.message);
    process.exit(1);
  }
}

if (require.main === module) {
  startServer();
}

module.exports = app;
