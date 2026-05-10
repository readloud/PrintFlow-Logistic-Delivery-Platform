const AuthService = require('../services/auth.service');
const { validateLogin, validateRegister } = require('../middleware/validation');
const logger = require('../utils/logger');

const AuthController = {
  register: async (req, res, next) => {
    try {
      const { error } = validateRegister(req.body);
      if (error) {
        return res.status(400).json({ error: error.details[0].message });
      }
      
      const result = await AuthService.register(req.body);
      res.status(201).json(result);
    } catch (error) {
      logger.error('Registration error:', error);
      next(error);
    }
  },
  
  login: async (req, res, next) => {
    try {
      const { error } = validateLogin(req.body);
      if (error) {
        return res.status(400).json({ error: error.details[0].message });
      }
      
      const result = await AuthService.login(req.body.email, req.body.password);
      res.json(result);
    } catch (error) {
      next(error);
    }
  },
  
  logout: async (req, res, next) => {
    try {
      await AuthService.logout(req.user.id);
      res.json({ message: 'Logged out successfully' });
    } catch (error) {
      next(error);
    }
  },
  
  refreshToken: async (req, res, next) => {
    try {
      const { refreshToken } = req.body;
      const result = await AuthService.refreshToken(refreshToken);
      res.json(result);
    } catch (error) {
      next(error);
    }
  },
  
  getProfile: async (req, res, next) => {
    try {
      const user = await AuthService.getProfile(req.user.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = AuthController;