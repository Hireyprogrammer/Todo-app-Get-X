const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const UserSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: [6, 'Password must be at least 6 characters long']
  },
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  verificationCode: {
    type: String,
    trim: true
  },
  verificationCodeExpires: {
    type: Date
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Hash password before saving
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
UserSchema.methods.comparePassword = async function(candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw error;
  }
};

// Generate verification code
UserSchema.methods.generateVerificationCode = function() {
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  this.verificationCode = code;
  this.verificationCodeExpires = new Date(Date.now() + 30 * 60000); // 30 minutes
  return code;
};

// Verify code method
UserSchema.methods.verifyCode = function(code) {
  if (!this.verificationCode || !this.verificationCodeExpires) {
    return false;
  }
  
  if (this.verificationCodeExpires < Date.now()) {
    return false;
  }

  const isValid = this.verificationCode === code;
  if (isValid) {
    this.isEmailVerified = true;
    this.verificationCode = undefined;
    this.verificationCodeExpires = undefined;
  }
  return isValid;
};

// Add virtual getter for verification status
UserSchema.virtual('isVerified').get(function() {
  return this.isEmailVerified === true;
});

// Ensure virtuals are included in JSON
UserSchema.set('toJSON', {
  virtuals: true,
  transform: function(doc, ret) {
    delete ret.password;
    delete ret.verificationCode;
    delete ret.verificationCodeExpires;
    return ret;
  }
});

const User = mongoose.model('User', UserSchema);

module.exports = User;
