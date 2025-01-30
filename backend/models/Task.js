const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  completed: {
    type: Boolean,
    default: false
  },
  taskList: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'TaskList',
    required: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  taskType: {
    type: String,
    enum: ['ICT', 'DEVELOPMENT', 'DESIGN', 'MEETING', 'BUG_FIX', 'FEATURE', 'OTHER'],
    default: 'OTHER'
  },
  status: {
    type: String,
    enum: ['TODO', 'IN_PROGRESS', 'REVIEW', 'DONE'],
    default: 'TODO'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  dueDate: {
    type: Date
  },
  startDate: {
    type: Date
  },
  notes: {
    type: String,
    trim: true,
    maxlength: 1000
  },
  tags: [{
    type: String,
    trim: true
  }],
  attachments: [{
    name: String,
    url: String,
    type: String
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for faster queries
TaskSchema.index({ taskList: 1, completed: 1 });
TaskSchema.index({ user: 1, completed: 1 });
TaskSchema.index({ taskType: 1 });
TaskSchema.index({ status: 1 });
TaskSchema.index({ dueDate: 1 });

const Task = mongoose.model('Task', TaskSchema);

module.exports = Task;
