# Todo App Backend

A Node.js/Express.js backend for a Todo application with user authentication and task management.

## Features

- User Authentication (Register, Login, Email Verification)
- Task Management
- User Profile Management
- Email Notifications
- Role-based Access Control

## Technologies Used
- Node.js
- Express.js
- MongoDB
- Mongoose
- JSON Web Token (JWT)
- Bcrypt.js
- Cors
- Dotenv

## Project Structure
```
backend/
│
├── models/
│   ├── User.js        # User data model
│   └── Task.js        # Task data model
│
├── routes/
│   ├── authRoutes.js  # Authentication endpoints
│   └── taskRoutes.js  # Task-related endpoints
│
├── middleware/
│   ├── authMiddleware.js     # Authentication middleware
│   └── profileValidation.js  # Profile validation middleware
│
├── .env               # Environment variables
├── server.js          # Main server configuration
└── package.json       # Project dependencies
```

## Getting Started

### Prerequisites
- Node.js (v16+ recommended)
- MongoDB
- npm or yarn

### Setup Instructions

1. Clone the repository
```bash
git clone https://github.com/yourusername/todo-app-backend.git
cd todo-app-backend
```

2. Install Dependencies
```bash
npm install
```

3. Configure Environment
- Copy `.env.example` to `.env`
- Update the following variables:
  - `PORT`: Backend server port (default: 5000)
  - `MONGODB_URI`: Your MongoDB connection string
  - `JWT_SECRET`: A long, random string for JWT signing
  - `EMAIL_SERVICE`: Email service provider
  - `EMAIL_USER`: Email address
  - `EMAIL_PASS`: Email password

4. Run the Application
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register`: Register new user
- `POST /api/auth/login`: User login
- `POST /api/auth/verify`: Verify email
- `POST /api/auth/reset-password`: Reset password
- `GET /api/auth/profile`: Get user profile
- `PUT /api/auth/profile`: Update user profile

### Tasks
- `GET /api/tasks`: Fetch all tasks
- `POST /api/tasks`: Create a new task
- `GET /api/tasks/:id`: Get a specific task

## Environment Variables
- `PORT`: Server port
- `MONGODB_URI`: MongoDB connection string
- `JWT_SECRET`: JWT token secret
- `EMAIL_SERVICE`: Email service provider
- `EMAIL_USER`: Email address
- `EMAIL_PASS`: Email password

## Deployment
- Ensure all environment variables are set
- Use a process manager like PM2 for production
- Set up proper MongoDB hosting

## Troubleshooting
- Check MongoDB connection
- Verify environment variables
- Ensure all dependencies are installed

## Security
- Use strong, unique JWT secret
- Implement proper input validation
- Keep dependencies updated

## Security Features
- JWT Authentication
- Password Hashing
- Email Verification
- Rate Limiting
- Input Validation
- Role-based Access Control

## License
MIT License

## Disclaimer
This is a sample implementation. Ensure proper security measures in production.

## Support
For issues or questions, please open a GitHub issue.

## Future Roadmap
- [ ] Add more advanced search capabilities
- [ ] Implement caching
- [ ] Add more comprehensive testing
- [ ] Create admin dashboard
