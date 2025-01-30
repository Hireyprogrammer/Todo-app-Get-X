const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// CORS Configuration
const corsOptions = {
  origin: [
    'http://localhost:3000',     // Web frontend
    'http://localhost:5000',     // Flutter web
    'http://10.0.2.2:5000',     // Android emulator
    'http://192.168.100.229:*',  // Your physical device
    'http://localhost:8080',     // Alternative port
    'capacitor://localhost',     // Capacitor
    'ionic://localhost',         // Ionic
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`📝 ${new Date().toISOString()} - ${req.method} ${req.url}`);
  console.log('Headers:', req.headers);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging Middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
.then(() => console.log('🌿 MongoDB connected successfully! 🚀'))
.catch((err) => console.error('❌ MongoDB connection error:', err));

// Import routes
const authRoutes = require('./routes/authRoutes');
const taskListRoutes = require('./routes/taskListRoutes');
const taskRoutes = require('./routes/taskRoutes');

// Route Prefixing
app.use('/api/auth', authRoutes);
app.use('/api/tasklists', taskListRoutes);
app.use('/api/tasks', taskRoutes);

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// Advanced Error Handling Middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Start server with port handling
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`📚 Book Store Backend is running on port ${PORT} 🎉`);
}).on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is in use. Please free up port ${PORT} and try again.`);
    process.exit(1);
  } else {
    console.error('Server error:', err);
    process.exit(1);
  }
});

// Graceful Shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    mongoose.connection.close(false, () => {
      console.log('MongoDB connection closed');
      process.exit(0);
    });
  });
});
