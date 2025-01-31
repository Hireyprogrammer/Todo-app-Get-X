const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');
const taskValidation = require('../middleware/taskValidation');
const jwt = require('jsonwebtoken');

// Protect all task routes
router.use(authMiddleware.verifyToken);

// Get all tasks
router.get('/', taskController.getAllTasks);

// Create new task
router.post('/', 
  taskValidation.validateTaskInput,
  taskController.createTask
);

// Toggle task completion
router.put('/:id/toggle', 
  taskValidation.validateTaskOwnership,
  taskController.toggleTask
);

// Delete task
router.delete('/:id', 
  taskValidation.validateTaskOwnership,
  taskController.deleteTask
);

module.exports = router; 