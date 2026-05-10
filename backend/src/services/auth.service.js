const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const UserModel = require('../models/user.model');
const { AppError } = require('../utils/helpers');
const logger = require('../utils/logger');

class AuthService {
  async register(userData) {
    const { email, password, name, phone, role } = userData;
    
    const existingUser = await UserModel.findByEmail(email);
    if (existingUser) {
      throw new AppError('User already exists', 400);
    }
    
    const hashedPassword = await bcrypt.hash(password, 12);
    
    const user = await UserModel.create({
      email,
      password: hashedPassword,
      name,
      phone,
      role: role || 'customer'
    });
    
    const token = this.generateToken(user.id, user.email, user.role);
    const refreshToken = this.generateRefreshToken(user.id);
    
    return {
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
      token,
      refreshToken
    };
  }
  
  async login(email, password) {
    const user = await UserModel.findByEmail(email);
    if (!user) {
      throw new AppError('Invalid credentials', 401);
    }
    
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw new AppError('Invalid credentials', 401);
    }
    
    const token = this.generateToken(user.id, user.email, user.role);
    const refreshToken = this.generateRefreshToken(user.id);
    
    return {
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
      token,
      refreshToken
    };
  }
  
  generateToken(userId, email, role) {
    return jwt.sign(
      { userId, email, role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
    );
  }
  
  generateRefreshToken(userId) {
    return jwt.sign(
      { userId },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );
  }
  
  async refreshToken(refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      const user = await UserModel.findById(decoded.userId);
      
      if (!user) {
        throw new AppError('Invalid refresh token', 401);
      }
      
      const newToken = this.generateToken(user.id, user.email, user.role);
      return { token: newToken };
    } catch (error) {
      throw new AppError('Invalid refresh token', 401);
    }
  }
  
  async logout(userId) {
    // Implement token blacklist with Redis
    logger.info(`User ${userId} logged out`);
    return true;
  }
  
  async getProfile(userId) {
    const user = await UserModel.findById(userId);
    if (!user) {
      throw new AppError('User not found', 404);
    }
    
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
}

module.exports = new AuthService();