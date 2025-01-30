const mongoose = require('mongoose');

const listTypeConfig = {
  PERSONAL: {
    icon: 'person_outline',
    defaultColor: '#6B66FF' // Purple
  },
  WORK: {
    icon: 'work_outline',
    defaultColor: '#FF6B6B' // Pink/Red
  },
  MOVIE: {
    icon: 'movie',
    defaultColor: '#66FF6B' // Green
  },
  SHOPPING: {
    icon: 'shopping_cart',
    defaultColor: '#FFB366' // Orange
  },
  SPORT: {
    icon: 'sports_basketball',
    defaultColor: '#66B3FF' // Blue
  },
  EVENT: {
    icon: 'event_note',
    defaultColor: '#FF66B3' // Pink
  },
  STUDY: {
    icon: 'school',
    defaultColor: '#B366FF' // Purple
  },
  TRAVEL: {
    icon: 'flight',
    defaultColor: '#66FFB3' // Turquoise
  },
  HEALTH: {
    icon: 'favorite',
    defaultColor: '#FF6666' // Red
  },
  CUSTOM: {
    icon: 'star_outline',
    defaultColor: '#808080' // Gray
  }
};

const TaskListSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 50
  },
  listType: {
    type: String,
    required: true,
    enum: Object.keys(listTypeConfig),
    default: 'PERSONAL'
  },
  icon: {
    type: String
  },
  customIcon: {
    type: String,
    trim: true
  },
  color: {
    type: String
  },
  description: {
    type: String,
    trim: true,
    maxlength: 200
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  isArchived: {
    type: Boolean,
    default: false
  },
  isPinned: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for task count
TaskListSchema.virtual('taskCount', {
  ref: 'Task',
  localField: '_id',
  foreignField: 'taskList',
  count: true
});

// Virtual for completed task count
TaskListSchema.virtual('completedTaskCount', {
  ref: 'Task',
  localField: '_id',
  foreignField: 'taskList',
  count: true,
  match: { completed: true }
});

// Pre-save middleware to set icon and color
TaskListSchema.pre('save', function(next) {
  try {
    const config = listTypeConfig[this.listType];
    
    // Set icon if not already set
    if (!this.icon) {
      this.icon = this.customIcon || config.icon;
    }
    
    // Set color if not already set
    if (!this.color) {
      this.color = config.defaultColor;
    }
    
    next();
  } catch (error) {
    next(error);
  }
});

// Static method to get all available list types with their configurations
TaskListSchema.statics.getListTypes = function() {
  return Object.entries(listTypeConfig).map(([type, config]) => ({
    type,
    icon: config.icon,
    defaultColor: config.defaultColor
  }));
};

const TaskList = mongoose.model('TaskList', TaskListSchema);

module.exports = TaskList;
