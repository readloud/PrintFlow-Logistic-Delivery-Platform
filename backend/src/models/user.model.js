const { prisma } = require('../config/database');

const UserModel = {
  findByEmail: async (email) => {
    return await prisma.user.findUnique({ where: { email } });
  },
  
  findById: async (id) => {
    return await prisma.user.findUnique({ where: { id } });
  },
  
  create: async (data) => {
    return await prisma.user.create({ data });
  },
  
  update: async (id, data) => {
    return await prisma.user.update({ where: { id }, data });
  },
  
  delete: async (id) => {
    return await prisma.user.delete({ where: { id } });
  },
  
  findAll: async (filters = {}, pagination = {}) => {
    const { page = 1, limit = 10 } = pagination;
    const skip = (page - 1) * limit;
    
    return await prisma.user.findMany({
      where: filters,
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' }
    });
  }
};

module.exports = UserModel;