const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authMiddleware = {
  verifyToken: async (req, res, next) => {
    try {
      // Get token from header
      const authHeader = req.header('Authorization');
      
      if (!authHeader) {
        console.log('No Authorization header found');
        return res.status(401).json({
          success: false,
          error: 'NO_TOKEN',
          message: 'No token provided. Authorization denied.'
        });
      }

      // Check if it starts with Bearer
      if (!authHeader.startsWith('Bearer ')) {
        console.log('Token does not start with Bearer');
        return res.status(401).json({
          success: false,
          error: 'INVALID_TOKEN_FORMAT',
          message: 'Token must be in Bearer format'
        });
      }

      // Get token without Bearer prefix
      const token = authHeader.split(' ')[1];
      
      console.log('Token received:', token.substring(0, 20) + '...');

      try {
        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET, {
          algorithms: ['HS256']
        });
        
        console.log('Token decoded successfully:', {
          userId: decoded.userId,
          email: decoded.email,
          role: decoded.role
        });

        // Get user from database
        const user = await User.findById(decoded.userId).select('-password');
        
        if (!user) {
          console.log('User not found for token');
          return res.status(401).json({
            success: false,
            error: 'USER_NOT_FOUND',
            message: 'User not found'
          });
        }

        // Add user to request object
        req.user = user;
        next();
      } catch (err) {
        console.error('Token verification error:', err.name);
        if (err.name === 'TokenExpiredError') {
          return res.status(401).json({
            success: false,
            error: 'TOKEN_EXPIRED',
            message: 'Token has expired. Please login again.'
          });
        }
        return res.status(401).json({
          success: false,
          error: 'INVALID_TOKEN',
          message: 'Token is not valid'
        });
      }
    } catch (error) {
      console.error('Auth middleware error:', error);
      res.status(500).json({
        success: false,
        error: 'SERVER_ERROR',
        message: 'Server error in auth middleware'
      });
    }
  },

  // Check if user is admin
  isAdmin: async (req, res, next) => {
    try {
      if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'ACCESS_DENIED',
          message: 'Admin access required'
        });
      }
      next();
    } catch (error) {
      console.error('Admin check error:', error);
      return res.status(500).json({
        error: 'SERVER_ERROR',
        message: 'Server error checking admin status'
      });
    }
  }
};

module.exports = authMiddleware;
