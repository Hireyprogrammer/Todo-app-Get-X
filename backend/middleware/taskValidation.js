const Task = require('../models/Task');

const taskValidation = {
  validateTaskOwnership: async (req, res, next) => {
    try {
      const taskId = req.params.id;
      const userId = req.user.id;

      const task = await Task.findById(taskId);
      
      if (!task) {
        return res.status(404).json({
          success: false,
          message: 'Task not found'
        });
      }

      // Check if task belongs to user
      if (task.user.toString() !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Access denied: Task belongs to another user'
        });
      }

      // Add task to request object for later use
      req.task = task;
      next();
    } catch (error) {
      console.error('Task validation error:', error);
      res.status(500).json({
        success: false,
        message: 'Error validating task ownership',
        error: error.message
      });
    }
  },

  validateTaskInput: (req, res, next) => {
    const { title } = req.body;

    if (!title || title.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Task title is required'
      });
    }

    if (title.trim().length > 200) {
      return res.status(400).json({
        success: false,
        message: 'Task title cannot exceed 200 characters'
      });
    }

    next();
  }
};

module.exports = taskValidation; 