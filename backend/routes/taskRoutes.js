const express = require('express');
const Task = require('../models/Task');
const TaskList = require('../models/TaskList');
const authMiddleware = require('../middleware/authMiddleware');
const { body, validationResult } = require('express-validator');

const router = express.Router();

// Validation middleware
const validateTask = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Task name is required')
    .isLength({ max: 200 })
    .withMessage('Task name cannot exceed 200 characters'),
  body('taskList')
    .notEmpty()
    .withMessage('Task list ID is required')
    .isMongoId()
    .withMessage('Invalid task list ID'),
  body('taskType')
    .optional()
    .isIn(['ICT', 'DEVELOPMENT', 'DESIGN', 'MEETING', 'BUG_FIX', 'FEATURE', 'OTHER'])
    .withMessage('Invalid task type'),
  body('status')
    .optional()
    .isIn(['TODO', 'IN_PROGRESS', 'REVIEW', 'DONE'])
    .withMessage('Invalid status'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('Invalid priority level'),
  body('dueDate')
    .optional()
    .isISO8601()
    .withMessage('Invalid date format'),
  body('notes')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Notes cannot exceed 1000 characters')
];

// Get all tasks for a specific task list
router.get('/list/:taskListId', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { status, taskType, priority } = req.query;
    const query = {
      taskList: req.params.taskListId,
      user: req.user.id
    };

    if (status) query.status = status;
    if (taskType) query.taskType = taskType;
    if (priority) query.priority = priority;

    const tasks = await Task.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      data: tasks
    });
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching tasks'
    });
  }
});

// Create a new task
router.post('/', [authMiddleware.verifyToken, validateTask], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    // Verify task list belongs to user
    const taskList = await TaskList.findOne({
      _id: req.body.taskList,
      user: req.user.id
    });

    if (!taskList) {
      return res.status(404).json({
        success: false,
        message: 'Task list not found'
      });
    }

    const task = new Task({
      ...req.body,
      user: req.user.id
    });

    await task.save();

    res.status(201).json({
      success: true,
      data: task
    });
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating task'
    });
  }
});

// Update task status
router.patch('/:id/status', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { status } = req.body;
    if (!['TODO', 'IN_PROGRESS', 'REVIEW', 'DONE'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    const task = await Task.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      { status },
      { new: true }
    );

    if (!task) {
      return res.status(404).json({
        success: false,
        message: 'Task not found'
      });
    }

    res.json({
      success: true,
      data: task
    });
  } catch (error) {
    console.error('Error updating task status:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating task status'
    });
  }
});

// Update task
router.put('/:id', [authMiddleware.verifyToken, validateTask], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const task = await Task.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      req.body,
      { new: true }
    );

    if (!task) {
      return res.status(404).json({
        success: false,
        message: 'Task not found'
      });
    }

    res.json({
      success: true,
      data: task
    });
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating task'
    });
  }
});

// Delete task
router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
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
      message: 'Error deleting task'
    });
  }
});

module.exports = router;
