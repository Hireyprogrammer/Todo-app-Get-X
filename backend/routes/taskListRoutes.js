const express = require('express');
const TaskList = require('../models/TaskList');
const Task = require('../models/Task');
const authMiddleware = require('../middleware/authMiddleware');
const { body, validationResult } = require('express-validator');

const router = express.Router();

// Get available list types
router.get('/types', authMiddleware.verifyToken, async (req, res) => {
  try {
    const listTypes = TaskList.getListTypes();
    res.json({
      success: true,
      data: listTypes
    });
  } catch (error) {
    console.error('Error fetching list types:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error fetching list types',
      error: error.message
    });
  }
});

// Validation middleware
const validateTaskList = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Task list name is required')
    .isLength({ max: 50 })
    .withMessage('Task list name cannot exceed 50 characters'),
  body('listType')
    .isIn(['PERSONAL', 'WORK', 'MOVIE', 'SHOPPING', 'EVENT', 'SPORT', 'STUDY', 'TRAVEL', 'HEALTH', 'CUSTOM'])
    .withMessage('Invalid list type'),
  body('color')
    .optional()
    .isHexColor()
    .withMessage('Invalid color format'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('Description cannot exceed 200 characters')
];

// Get all task lists for the authenticated user
router.get('/', authMiddleware.verifyToken, async (req, res) => {
  try {
    console.log('Fetching task lists...');
    console.log('User:', req.user);
    console.log('Query:', req.query);
    
    const { type, archived } = req.query;
    const query = { user: req.user.id };

    if (type) {
      query.listType = type.toUpperCase();
    }

    if (archived !== undefined) {
      query.isArchived = archived === 'true';
    }

    console.log('Querying task lists with:', query);
    
    const taskLists = await TaskList.find(query)
      .populate(['taskCount'])
      .sort({ isPinned: -1, createdAt: -1 });

    console.log('Task lists fetched:', taskLists);
    
    res.json({
      success: true,
      data: taskLists
    });
  } catch (error) {
    console.error('Error fetching task lists:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error fetching task lists',
      error: error.message
    });
  }
});

// Create a new task list
router.post('/', [authMiddleware.verifyToken, validateTaskList], async (req, res) => {
  try {
    console.log('Creating task list...');
    console.log('User:', req.user);
    console.log('Request body:', req.body);
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('Validation errors:', errors.array());
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { name, listType, color, description, customIcon } = req.body;
    
    console.log('Creating TaskList with data:', {
      name,
      listType,
      color,
      description,
      customIcon,
      user: req.user.id
    });
    
    const taskList = new TaskList({
      name,
      listType: listType.toUpperCase(),
      color,
      description,
      customIcon,
      user: req.user.id
    });

    console.log('TaskList instance created:', taskList);

    const savedTaskList = await taskList.save();
    console.log('TaskList saved successfully:', savedTaskList);

    res.status(201).json({
      success: true,
      data: savedTaskList
    });
  } catch (error) {
    console.error('Error creating task list:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error creating task list',
      error: error.message
    });
  }
});

// Update a task list
router.put('/:id', [authMiddleware.verifyToken, validateTaskList], async (req, res) => {
  try {
    console.log('Updating task list...');
    console.log('User:', req.user);
    console.log('Request body:', req.body);
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('Validation errors:', errors.array());
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { name, listType, color, description, isArchived, isPinned } = req.body;
    
    console.log('Updating TaskList with data:', {
      name,
      listType,
      color,
      description,
      isArchived,
      isPinned,
      user: req.user.id
    });
    
    const taskList = await TaskList.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      { 
        name,
        listType: listType.toUpperCase(),
        color,
        description,
        isArchived,
        isPinned
      },
      { new: true }
    ).populate(['taskCount']);

    console.log('TaskList updated:', taskList);

    if (!taskList) {
      console.log('Task list not found');
      return res.status(404).json({
        success: false,
        message: 'Task list not found'
      });
    }

    res.json({
      success: true,
      data: taskList
    });
  } catch (error) {
    console.error('Error updating task list:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error updating task list',
      error: error.message
    });
  }
});

// Toggle pin status
router.patch('/:id/pin', authMiddleware.verifyToken, async (req, res) => {
  try {
    console.log('Toggling pin status...');
    console.log('User:', req.user);
    
    const taskList = await TaskList.findOne({ _id: req.params.id, user: req.user.id });
    
    console.log('TaskList found:', taskList);

    if (!taskList) {
      console.log('Task list not found');
      return res.status(404).json({
        success: false,
        message: 'Task list not found'
      });
    }

    taskList.isPinned = !taskList.isPinned;
    console.log('Toggling pin status to:', taskList.isPinned);
    
    await taskList.save();
    console.log('TaskList saved successfully:', taskList);

    res.json({
      success: true,
      data: taskList
    });
  } catch (error) {
    console.error('Error toggling pin status:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error toggling pin status',
      error: error.message
    });
  }
});

// Toggle archive status
router.patch('/:id/archive', authMiddleware.verifyToken, async (req, res) => {
  try {
    console.log('Toggling archive status...');
    console.log('User:', req.user);
    
    const taskList = await TaskList.findOne({ _id: req.params.id, user: req.user.id });
    
    console.log('TaskList found:', taskList);

    if (!taskList) {
      console.log('Task list not found');
      return res.status(404).json({
        success: false,
        message: 'Task list not found'
      });
    }

    taskList.isArchived = !taskList.isArchived;
    console.log('Toggling archive status to:', taskList.isArchived);
    
    await taskList.save();
    console.log('TaskList saved successfully:', taskList);

    res.json({
      success: true,
      data: taskList
    });
  } catch (error) {
    console.error('Error toggling archive status:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error toggling archive status',
      error: error.message
    });
  }
});

// Delete a task list and its tasks
router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
  try {
    console.log('Deleting task list...');
    console.log('User:', req.user);
    
    const taskList = await TaskList.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id
    });

    console.log('TaskList deleted:', taskList);

    if (!taskList) {
      console.log('Task list not found');
      return res.status(404).json({
        success: false,
        message: 'Task list not found'
      });
    }

    // Delete all tasks in the list
    await Task.deleteMany({ taskList: req.params.id });
    console.log('Tasks deleted successfully');

    res.json({
      success: true,
      message: 'Task list and associated tasks deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting task list:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Error deleting task list',
      error: error.message
    });
  }
});

module.exports = router;
