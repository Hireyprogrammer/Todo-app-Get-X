const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');
const { body, validationResult } = require('express-validator');
const { sendWelcomeEmail, sendPasswordResetEmail, sendVerificationPinEmail, sendResetPinEmail } = require('../utils/emailService');
const crypto = require('crypto');
const sendEmail = require('../utils/sendEmail');

const router = express.Router();

// Generate 6-digit PIN
const generatePin = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Input Validation Middleware
const validateRegistration = [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
];

// Password Reset Validation
const validatePasswordReset = [
  body('email').trim().isEmail().withMessage('Invalid email address')
];

// User Registration
router.post('/register', validateRegistration, async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: errors.array()
      });
    }

    const { username, email, password } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({
      $or: [{ email }, { username }]
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: existingUser.email === email ? 'Email already registered' : 'Username already taken'
      });
    }

    // Create new user
    const user = new User({
      username,
      email,
      password
    });

    // Generate verification code
    const verificationCode = user.generateVerificationCode();
    
    // Debug logging
    console.log('\n=== Registration Debug Info ===');
    console.log('Generated verification details:', {
      email: user.email,
      verificationCode: verificationCode,
      storedCode: user.verificationCode,
      expiryTime: user.verificationCodeExpires
    });

    // Save user
    await user.save();

    // Send verification email
    const emailData = {
      email: user.email,
      subject: 'Email Verification Code',
      html: `
        <h1>Welcome to Todo App!</h1>
        <p>Your verification code is: <strong>${verificationCode}</strong></p>
        <p>This code will expire in 30 minutes.</p>
      `
    };

    await sendEmail(emailData);

    res.status(201).json({
      success: true,
      message: 'Registration successful. Please check your email for verification code.',
      data: {
        userId: user._id,
        username: user.username,
        email: user.email
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Error in registration',
      error: error.message
    });
  }
});

// Resend verification code
router.post('/resend-verification', async (req, res) => {
  try {
    console.log('Received resend verification request:', req.body);
    const { email } = req.body;

    // Validate email
    if (!email) {
      console.log('Missing email');
      return res.status(400).json({
        success: false,
        message: 'Email is required',
        error: 'VALIDATION_ERROR'
      });
    }

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      console.log('User not found:', email);
      return res.status(404).json({
        success: false,
        message: 'User not found',
        error: 'USER_NOT_FOUND'
      });
    }

    // Check if already verified
    if (user.isEmailVerified) {
      console.log('Email already verified:', email);
      return res.status(400).json({
        success: false,
        message: 'Email is already verified',
        error: 'ALREADY_VERIFIED'
      });
    }

    // Generate new verification code
    const verificationCode = user.generateVerificationCode();
    await user.save();

    console.log('Generated new verification code for:', email);

    // Send new verification email
    const emailData = {
      email: user.email,
      subject: 'New Email Verification Code',
      html: `
        <h1>New Verification Code For Todo-App</h1>
        <p>Your new verification code is: <strong>${verificationCode}</strong></p>
        <p>This code will expire in 30 minutes.</p>
      `
    };

    await sendEmail(emailData);
    console.log('Sent new verification email to:', email);

    res.status(200).json({
      success: true,
      message: 'New verification code sent successfully'
    });

  } catch (error) {
    console.error('Error in resend verification:', error);
    res.status(500).json({
      success: false,
      message: 'Error sending verification code',
      error: error.message
    });
  }
});

// Verify Email with PIN
router.post('/verify-email', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('pin').trim().isLength({ min: 6, max: 6 }).withMessage('Invalid PIN code')
], async (req, res) => {
  try {
    console.log('Received verification request:', req.body);
    const { email, pin, otp } = req.body;
    const verificationCode = pin || otp; // Accept either pin or otp

    // Validate input
    if (!email || !verificationCode) {
      console.log('Missing email or verification code');
      return res.status(400).json({
        success: false,
        message: 'Email and verification code are required',
        error: 'VALIDATION_ERROR'
      });
    }

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      console.log('User not found:', email);
      return res.status(404).json({
        success: false,
        message: 'User not found',
        error: 'USER_NOT_FOUND'
      });
    }

    console.log('\n=== Verification Debug Info ===');
    console.log('User found:', {
      email: user.email,
      isEmailVerified: user.isEmailVerified,
      hasVerificationCode: !!user.verificationCode,
      verificationCode: user.verificationCode,
      verificationCodeExpires: user.verificationCodeExpires,
      currentTime: new Date(),
      providedCode: verificationCode
    });

    // Check if already verified
    if (user.isEmailVerified) {
      console.log('Email already verified:', email);
      return res.status(400).json({
        success: false,
        message: 'Email is already verified',
        error: 'ALREADY_VERIFIED'
      });
    }

    // Check if verification code exists and is valid
    if (!user.verificationCode || !user.verificationCodeExpires) {
      console.log('No verification code found');
      return res.status(400).json({
        success: false,
        message: 'No verification code found. Please request a new code.',
        error: 'NO_CODE'
      });
    }

    // Check if code has expired
    if (user.verificationCodeExpires < new Date()) {
      console.log('Verification code expired');
      return res.status(400).json({
        success: false,
        message: 'Verification code has expired. Please request a new code.',
        error: 'CODE_EXPIRED'
      });
    }

    // Check if code matches
    if (user.verificationCode !== verificationCode) {
      console.log('Invalid verification code');
      return res.status(400).json({
        success: false,
        message: 'Invalid verification code',
        error: 'INVALID_CODE'
      });
    }

    // Update user verification status
    user.isEmailVerified = true;
    user.verificationCode = undefined;
    user.verificationCodeExpires = undefined;
    await user.save();

    console.log('Email verified successfully for:', email);

    // Generate JWT token with 5 days expiration
    const token = jwt.sign(
      { 
        userId: user._id,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified
      },
      process.env.JWT_SECRET,
      { 
        expiresIn: '5d',  // 5 days in seconds
        algorithm: 'HS256'
      }
    );

    // Send response with token
    res.json({
      success: true,
      message: 'Email verified successfully',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        isVerified: true
      }
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      success: false,
      error: 'VERIFICATION_FAILED',
      message: 'Failed to verify email'
    });
  }
});

// Resend Verification PIN
router.post('/resend-verification', [
  body('email').trim().isEmail().withMessage('Invalid email address')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      error: 'Validation Failed', 
      details: errors.array() 
    });
  }

  try {
    const { email } = req.body;

    const user = await User.findOne({ email, isVerified: false });
    if (!user) {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Invalid email or account already verified'
      });
    }

    // Generate new verification PIN
    const verificationPin = generatePin();
    const verificationPinExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Update user with new PIN
    user.verificationPin = verificationPin;
    user.verificationPinExpiry = verificationPinExpiry;
    await user.save();

    // Send new verification PIN email
    await sendVerificationPinEmail(user.email, user.username, verificationPin);

    res.json({
      message: 'New verification code sent successfully'
    });
  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      error: 'PIN_RESEND_FAILED',
      message: 'Failed to resend verification code'
    });
  }
});

// User Login
router.post('/login', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('\n=== Login Attempt ===');
    console.log('Email:', email);

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      console.log('No user found with email:', email);
      return res.status(401).json({
        success: false,
        error: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Debug log to check verification status
    console.log('User verification status:', {
      id: user._id,
      email: user.email,
      isEmailVerified: user.isEmailVerified,
      isVerified: user.isVerified // Check if there's a naming conflict
    });

    // Check password first
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      console.log('Password mismatch for:', email);
      return res.status(401).json({
        success: false,
        error: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Check if email is verified
    if (user.isEmailVerified !== true) {
      console.log('User not verified:', email);
      
      // Generate new verification code
      const verificationCode = user.generateVerificationCode();
      await user.save();

      // Send new verification email
      const emailData = {
        email: user.email,
        subject: 'Email Verification Code',
        html: `
          <h1>Email Verification Required</h1>
          <p>Please verify your email to login. Your verification code is: <strong>${verificationCode}</strong></p>
          <p>This code will expire in 30 minutes.</p>
        `
      };

      await sendEmail(emailData);

      return res.status(401).json({
        success: false,
        error: 'EMAIL_NOT_VERIFIED',
        message: 'Please verify your email before logging in. A new verification code has been sent to your email.'
      });
    }

    // Generate token with 5 days expiration (432000 seconds)
    const token = jwt.sign(
      { 
        userId: user._id,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified
      },
      process.env.JWT_SECRET,
      { 
        expiresIn: 432000,  // 5 days in seconds (5 * 24 * 60 * 60)
        algorithm: 'HS256'
      }
    );

    console.log('Login successful for:', email);
    console.log('Token generated with 5 days expiration');

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        isVerified: user.isVerified,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'LOGIN_FAILED',
      message: 'An error occurred during login'
    });
  }
});

// Get User Profile (Protected Route)
router.get('/profile', authMiddleware.verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ 
        error: 'USER_NOT_FOUND',
        message: 'User not found' 
      });
    }
    
    res.json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profile: user.profile,
        preferences: user.preferences
      }
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ 
      error: 'SERVER_ERROR',
      message: 'Failed to fetch user profile' 
    });
  }
});

// Profile Management Routes
// Update User Profile
router.put('/profile', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { 
      firstName, 
      lastName, 
      bio, 
      phoneNumber, 
      address,
      preferences 
    } = req.body;

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update profile fields
    user.profile.firstName = firstName || user.profile.firstName;
    user.profile.lastName = lastName || user.profile.lastName;
    user.profile.bio = bio || user.profile.bio;
    user.profile.phoneNumber = phoneNumber || user.profile.phoneNumber;

    // Update address if provided
    if (address) {
      user.profile.address = {
        street: address.street || user.profile.address.street,
        city: address.city || user.profile.address.city,
        state: address.state || user.profile.address.state,
        country: address.country || user.profile.address.country,
        zipCode: address.zipCode || user.profile.address.zipCode
      };
    }

    // Update preferences
    if (preferences) {
      user.preferences.newsletter = preferences.newsletter ?? user.preferences.newsletter;
      user.preferences.darkMode = preferences.darkMode ?? user.preferences.darkMode;
    }

    await user.save();

    res.json({ 
      success: true,
      message: 'Profile updated successfully', 
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profile: user.profile,
        preferences: user.preferences
      } 
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Upload Avatar
router.post('/avatar', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { avatarUrl } = req.body;

    if (!avatarUrl) {
      return res.status(400).json({ message: 'Avatar URL is required' });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.profile.avatar = avatarUrl;
    await user.save();

    res.json({ 
      success: true,
      message: 'Avatar updated successfully', 
      avatarUrl: user.profile.avatar 
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get Public Profile (for other users to view)
router.get('/profile/:username', async (req, res) => {
  try {
    const user = await User.findOne({ username: req.params.username })
      .select('username profile.firstName profile.lastName profile.bio profile.avatar');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      success: true,
      user: {
        username: user.username,
        firstName: user.profile.firstName,
        lastName: user.profile.lastName,
        bio: user.profile.bio,
        avatar: user.profile.avatar
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Request Password Reset (Step 1)
router.post('/forgot-password', [
  body('email').trim().isEmail().withMessage('Invalid email address')
], async (req, res) => {
  try {
    const { email } = req.body;
    console.log('\n=== Password Reset Request ===');
    console.log('Email:', email);

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'No user found with this email address'
      });
    }

    // Generate reset PIN
    const resetPin = generatePin();
    const resetPinExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Save reset PIN
    user.resetPin = resetPin;
    user.resetPinExpiry = resetPinExpiry;
    await user.save();
    console.log('Reset PIN generated');

    // Send reset PIN email
    await sendResetPinEmail(email, user.username, resetPin);
    console.log('Reset PIN email sent');

    res.json({
      message: 'Password reset instructions have been sent to your email'
    });
  } catch (error) {
    console.error('Password reset request error:', error);
    res.status(500).json({
      error: 'RESET_REQUEST_FAILED',
      message: 'Failed to process password reset request'
    });
  }
});

// Reset Password with PIN (Step 2)
router.post('/reset-password', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('pin').trim().isLength({ min: 6, max: 6 }).withMessage('Invalid PIN'),
  body('newPassword').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
  try {
    const { email, pin, newPassword } = req.body;
    console.log('\n=== Password Reset ===');
    console.log('Email:', email);

    // Find user with valid reset PIN
    const user = await User.findOne({
      email,
      resetPin: pin,
      resetPinExpiry: { $gt: Date.now() }
    });

    if (!user) {
      console.log('Invalid or expired PIN');
      return res.status(400).json({
        error: 'INVALID_PIN',
        message: 'Invalid or expired reset PIN'
      });
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);
    console.log('New password hashed');

    // Update password and clear reset PIN
    user.password = hashedPassword;
    user.resetPin = undefined;
    user.resetPinExpiry = undefined;
    await user.save();
    console.log('Password updated successfully');

    res.json({
      message: 'Password has been reset successfully. Please login with your new password.'
    });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      error: 'RESET_FAILED',
      message: 'Failed to reset password'
    });
  }
});

// Direct password reset (FOR TESTING ONLY)
router.post('/reset-password-direct', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('newPassword').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    console.log('\n=== Direct Password Reset ===');
    console.log('Email:', email);

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'No user found with this email address'
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();
    console.log('Password updated successfully');

    res.json({
      message: 'Password has been reset successfully. Please login with your new password.'
    });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      error: 'RESET_FAILED',
      message: 'Failed to reset password'
    });
  }
});

// Admin Initialization Route
router.post('/init-admin', async (req, res) => {
  try {
    // Check if admin already exists
    const existingAdmin = await User.findOne({ role: 'admin' });
    if (existingAdmin) {
      return res.status(400).json({ 
        error: 'ADMIN_ALREADY_EXISTS', 
        message: 'An admin user has already been created' 
      });
    }

    // Create admin using environment variables
    const salt = await bcrypt.genSalt(Number(process.env.SALT_ROUNDS));
    const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD, salt);

    const adminUser = new User({
      username: 'todo_admin',
      email: process.env.ADMIN_EMAIL,
      password: hashedPassword,
      role: 'admin'
    });

    await adminUser.save();

    res.status(201).json({ 
      success: true,
      message: 'Admin user created successfully', 
      email: process.env.ADMIN_EMAIL 
    });
  } catch (error) {
    console.error('Admin initialization error:', error);
    res.status(500).json({ 
      error: 'ADMIN_INIT_FAILED', 
      message: 'Failed to create admin user' 
    });
  }
});

// Health Check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
