const Task = require('../models/Task');

const taskController = {
  // Get all tasks for a user
  getAllTasks: async (req, res) => {
    try {
      const tasks = await Task.find({ user: req.user.id }).sort({ createdAt: -1 });
      res.json({
        success: true,
        tasks
      });
    } catch (error) {
      console.error('Error fetching tasks:', error);
      res.status(500).json({
        success: false,
        message: 'Error fetching tasks',
        error: error.message
      });
    }
  },

  // Create new task
  createTask: async (req, res) => {
    try {
      const { title } = req.body;
      
      const task = new Task({
        title,
        user: req.user.id,
        completed: false
      });

      await task.save();
      
      res.status(201).json({
        success: true,
        task
      });
    } catch (error) {
      console.error('Error creating task:', error);
      res.status(500).json({
        success: false,
        message: 'Error creating task',
        error: error.message
      });
    }
  },

  // Toggle task completion
  toggleTask: async (req, res) => {
    try {
      // Task is already validated and available in req.task
      const task = req.task;
      task.completed = !task.completed;
      await task.save();

      res.json({
        success: true,
        task
      });
    } catch (error) {
      console.error('Error toggling task:', error);
      res.status(500).json({
        success: false,
        message: 'Error toggling task',
        error: error.message
      });
    }
  },

  // Delete task
  deleteTask: async (req, res) => {
    try {
      const task = await Task.findOneAndDelete({
        _id: req.params.id,
        user: req.user.id
      });

      if (!task) {
        return res.status(404).json({
          success: false,
          message: 'Task not found'
        });
      }

      res.json({
        success: true,
        message: 'Task deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting task:', error);
      res.status(500).json({
        success: false,
        message: 'Error deleting task',
        error: error.message
      });
    }
  }
};

module.exports = taskController; 