# 📚 Book Store Backend - Postman Endpoint Testing Guide

## 🔐 Authentication Endpoints

### 1. User Registration
- **Endpoint**: `POST /api/auth/register`
- **Purpose**: Create a new user account
- **Full URL**: `http://localhost:5000/api/auth/register`

#### Validation Requirements
- **Username**:
  - Minimum length: 3 characters
  - Cannot be empty
  - Must be unique
- **Email**:
  - Must be a valid email format
  - Cannot be empty
  - Must be unique
- **Password**:
  - Minimum length: 6 characters
  - No strict complexity requirements in current implementation

#### JSON Request Body
```json
{
    "username": "Abdifitah",
    "email": "abdifitah@gmail.com", 
    "password": "mohamed11",
    "role": "user"
}
```

#### Possible Validation Scenarios
1. **Successful Registration**
   - Status Code: 201 Created
   - Response includes:
     - User details
     - JWT authentication token
     - Success message

2. **Validation Failures**
   - Status Code: 400 Bad Request
   - Possible error scenarios:
     - Username too short
     - Invalid email format
     - Password too weak
     - Missing required fields

3. **Duplicate User Failures**
   - Status Code: 409 Conflict
   - Occurs when:
     - Email already exists
     - Username already taken

#### Headers
- `Content-Type`: `application/json`

#### Common Error Responses
```json
{
    "error": "VALIDATION_ERROR",
    "details": [
        {
            "msg": "Username must be at least 3 characters",
            "param": "username"
        }
    ]
}
```

#### Troubleshooting Tips
- Ensure server is running
- Check network connectivity
- Verify endpoint URL (`/api/auth/register`)
- Validate JSON payload
- Check console logs on server side

### 2. User Login
- **Endpoint**: `POST /auth/login`
- **Purpose**: Authenticate user and get JWT token

#### JSON Request Body
```json
{
    "email": "hireyprogrammer@gmail.com",
    "password": "maxamuud11"
}
```

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: User details, JWT token
- **Failure**: 
  - Status Code: 401 
  - Reasons: Invalid credentials

### 3. Email Verification with PIN
- **Endpoint**: `POST /api/auth/verify-email`
- **Purpose**: Verify user's email using the PIN code received in email
- **Full URL**: `http://localhost:5000/api/auth/verify-email`

#### Request Body
```json
{
    "email": "abdifitah@gmail.com",
    "pin": "123456"  // Replace with actual PIN from email
}
```

#### Validation Requirements
- **Email**:
  - Must be a valid email format
  - Must match registered email
- **PIN**:
  - Must be exactly 6 digits
  - Must be valid and not expired
  - Case sensitive

#### Possible Responses
1. **Successful Verification**
   - Status Code: 200 OK
   ```json
   {
       "message": "Email verified successfully",
       "token": "jwt_token_here",
       "user": {
           "id": "user_id",
           "username": "Abdifitah",
           "email": "abdifitah@gmail.com",
           "isVerified": true
       }
   }
   ```

2. **Invalid PIN**
   - Status Code: 400 Bad Request
   ```json
   {
       "error": "INVALID_PIN",
       "message": "Invalid or expired verification code"
   }
   ```

3. **Validation Error**
   - Status Code: 400 Bad Request
   ```json
   {
       "error": "Validation Failed",
       "details": [
           {
               "msg": "Invalid PIN code",
               "param": "pin",
               "location": "body"
           }
       ]
   }
   ```

### 4. Resend Verification PIN
- **Endpoint**: `POST /api/auth/resend-verification`
- **Purpose**: Request a new verification PIN if the original expired
- **Full URL**: `http://localhost:5000/api/auth/resend-verification`

#### Request Body
```json
{
    "email": "abdifitah@gmail.com"
}
```

#### Validation Requirements
- **Email**:
  - Must be a valid email format
  - Must belong to an unverified user

#### Possible Responses
1. **Success**
   - Status Code: 200 OK
   ```json
   {
       "message": "New verification code sent successfully"
   }
   ```

2. **Invalid Request**
   - Status Code: 400 Bad Request
   ```json
   {
       "error": "INVALID_REQUEST",
       "message": "Invalid email or account already verified"
   }
   ```

### Testing Flow
1. **Register New User**:
   - Send POST request to `/api/auth/register`
   - Save the user ID from response
   - Check your email for verification PIN

2. **Verify Email**:
   - Copy PIN from email
   - Send POST request to `/api/auth/verify-email`
   - Save the JWT token from response

3. **Try Login (Optional)**:
   - Attempt login with verified credentials
   - Should receive successful login response with token

4. **Test PIN Expiry (Optional)**:
   - Wait 15 minutes for PIN to expire
   - Try verifying with expired PIN (should fail)
   - Request new PIN using resend endpoint
   - Verify with new PIN

### Important Notes
- PINs expire after 15 minutes
- Each email can only have one active PIN at a time
- Requesting a new PIN invalidates any previous PIN
- Users cannot log in until email is verified

## 📖 Book Endpoints

### 3. Create Book (Admin Only)
- **Endpoint**: `POST /books`
- **Purpose**: Add a new book to the store
- **Authorization**: Requires Admin JWT Token

#### JSON Request Body
```json
{
    "title": "The Digital Renaissance",
    "author": "Alex Technovation",
    "isbn": "978-1234567890",
    "description": "A comprehensive exploration of digital transformation",
    "price": 29.99,
    "priceType": "Paid",
    "genre": "Non-Fiction, Technology",
    "bookDetails": {
        "publisher": "Tech Insights Press",
        "publicationDate": "2024-01-15",
        "language": "English"
    },
    "images": {
        "coverImage": "https://example.com/book-cover.jpg"
    },
    "format": "Hardcover",
    "pageCount": 350,
    "stockInfo": {
        "inStock": 500,
        "lowStockThreshold": 50
    },
    "tags": ["technology", "digital transformation"]
}
```

#### Expected Responses
- **Success**: 
  - Status Code: 201 Created
  - Contains: Created book details
- **Failure**: 
  - Status Code: 400/401/403
  - Reasons: Missing fields, unauthorized, duplicate ISBN

### 4. Get All Books
- **Endpoint**: `GET /books`
- **Purpose**: Retrieve list of books with filtering
- **Query Parameters**:
  - `page`: Page number (default: 1)
  - `limit`: Books per page (default: 10)
  - `genre`: Filter by book genre
  - `minPrice`: Minimum book price
  - `maxPrice`: Maximum book price
  - `search`: Search by title, author, or tags

#### Example Request URL
```
/books?page=1&limit=10&genre=Technology&minPrice=10&maxPrice=50&search=digital
```

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: Books array, pagination info
- **Failure**: 
  - Status Code: 500
  - Reasons: Server error

### 5. Get Book by ID
- **Endpoint**: `GET /books/:id`
- **Purpose**: Retrieve specific book details

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: Complete book details
- **Failure**: 
  - Status Code: 404
  - Reasons: Book not found

### 6. Update Book (Admin Only)
- **Endpoint**: `PUT /books/:id`
- **Purpose**: Update book details
- **Authorization**: Requires Admin JWT Token

#### JSON Request Body (Partial Update)
```json
{
    "price": 34.99,
    "stockInfo": {
        "inStock": 450
    },
    "description": "Updated book description"
}
```

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: Updated book details
- **Failure**: 
  - Status Code: 400/401/404
  - Reasons: Invalid data, unauthorized, book not found

## 🖥️ Localhost Configuration

### Local Server Setup
- **Default Port**: 5000
- **Base URL**: `http://localhost:5000`
- **Environment**: Development

### Starting Local Server
```bash
# Using npm
npm start

# Using nodemon (for development with auto-reload)
npm run dev
```

### Localhost Endpoint URLs
- **Full Base URL**: `http://localhost:5000/api/v1`
- **Authentication Base**: `http://localhost:5000/auth`
- **Books Base**: `http://localhost:5000/books`

### Network Configuration
- **Hostname**: `localhost`
- **IP Address**: `127.0.0.1`
- **Port**: `5000`

### Postman Localhost Configuration
1. Create a new Postman Environment
2. Add these variables:
   - `base_url`: `http://localhost:5000`
   - `local_host`: `localhost`
   - `local_port`: `5000`

### Troubleshooting Localhost
- Ensure no other service is using port 5000
- Check network connectivity
- Verify endpoint URL
- Check console logs on server side

## 🛠 Postman Setup Tips

1. Create Environment Variables:
   - `base_url`: Your server URL (e.g., `http://localhost:5000`)
   - `admin_token`: Your admin JWT token
   - `book_id`: ID of a created book

2. Authentication Flow:
   - Register/Login to get JWT token
   - Use token in Authorization header for protected routes

3. Common Headers:
   - `Content-Type`: `application/json`
   - `Authorization`: `Bearer YOUR_JWT_TOKEN`

## 🚨 Error Handling

- Always check status codes
- Review error messages in response body
- Ensure correct authentication for admin routes

## 📝 Testing Checklist

- [ ] Register new user
- [ ] Login and get token
- [ ] Create book as admin
- [ ] Retrieve all books
- [ ] Get specific book by ID
- [ ] Update book details
- [ ] Test error scenarios

Happy Testing! 🎉🚀

# 📚 Book Store API Documentation

## Base URL
```
http://localhost:5000/api
```

## 🔐 Authentication Endpoints

### 1. Register User
- **Endpoint**: `POST /auth/register`
- **Description**: Register a new user account
- **Request Body**:
```json
{
    "username": "testuser",
    "email": "user@example.com",
    "password": "password123",
    "role": "user"  // Optional, defaults to "user"
}
```
- **Response (201)**:
```json
{
    "message": "Registration successful. Please check your email for the verification code.",
    "user": {
        "id": "user_id",
        "username": "testuser",
        "email": "user@example.com",
        "isVerified": false
    }
}
```

### 2. Verify Email
- **Endpoint**: `POST /auth/verify-email`
- **Description**: Verify email using PIN code
- **Request Body**:
```json
{
    "email": "user@example.com",
    "pin": "123456"
}
```
- **Response (200)**:
```json
{
    "message": "Email verified successfully",
    "token": "jwt_token",
    "user": {
        "id": "user_id",
        "username": "testuser",
        "email": "user@example.com",
        "isVerified": true
    }
}
```

### 3. Resend Verification PIN
- **Endpoint**: `POST /auth/resend-verification`
- **Description**: Request a new verification PIN
- **Request Body**:
```json
{
    "email": "user@example.com"
}
```
- **Response (200)**:
```json
{
    "message": "New verification code sent successfully"
}
```

### 4. Login
- **Endpoint**: `POST /auth/login`
- **Description**: Authenticate user and get token
- **Request Body**:
```json
{
    "email": "user@example.com",
    "password": "password123"
}
```
- **Response (200)**:
```json
{
    "message": "Login successful",
    "token": "jwt_token",
    "user": {
        "id": "user_id",
        "username": "testuser",
        "email": "user@example.com",
        "role": "user",
        "isVerified": true
    }
}
```

### 5. Reset Password Request
- **Endpoint**: `POST /auth/forgot-password`
- **Description**: Request password reset
- **Request Body**:
```json
{
    "email": "user@example.com"
}
```
- **Response (200)**:
```json
{
    "message": "Password reset email sent successfully"
}
```

### 6. Reset Password
- **Endpoint**: `POST /auth/reset-password`
- **Description**: Reset password using token
- **Request Body**:
```json
{
    "token": "reset_token",
    "newPassword": "newpassword123"
}
```
- **Response (200)**:
```json
{
    "message": "Password reset successful"
}
```

### 7. Get User Profile
- **Endpoint**: `GET /auth/profile`
- **Description**: Get authenticated user's profile
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Response (200)**:
```json
{
    "success": true,
    "user": {
        "id": "user_id",
        "username": "testuser",
        "email": "user@example.com",
        "profile": {
            "firstName": "John",
            "lastName": "Doe",
            "bio": "Book lover"
        }
    }
}
```

### 8. Update Profile
- **Endpoint**: `PUT /auth/profile`
- **Description**: Update user profile
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Request Body**:
```json
{
    "firstName": "John",
    "lastName": "Doe",
    "bio": "Book lover",
    "phoneNumber": "+1234567890",
    "address": {
        "street": "123 Book St",
        "city": "Reading",
        "state": "CA",
        "zipCode": "12345"
    }
}
```
- **Response (200)**:
```json
{
    "message": "Profile updated successfully",
    "user": {
        "id": "user_id",
        "profile": {
            "firstName": "John",
            "lastName": "Doe",
            "bio": "Book lover",
            "phoneNumber": "+1234567890",
            "address": {
                "street": "123 Book St",
                "city": "Reading",
                "state": "CA",
                "zipCode": "12345"
            }
        }
    }
}
```

## 📚 Book Endpoints

### 1. Create Book (Admin Only)
- **Endpoint**: `POST /books`
- **Description**: Add a new book
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Request Body**:
```json
{
    "title": "The Great Book",
    "author": "John Author",
    "description": "A wonderful book about...",
    "price": 29.99,
    "category": "Fiction",
    "isbn": "978-3-16-148410-0",
    "stockQuantity": 100
}
```
- **Response (201)**:
```json
{
    "message": "Book created successfully",
    "book": {
        "id": "book_id",
        "title": "The Great Book",
        "author": "John Author",
        "price": 29.99,
        "category": "Fiction",
        "isbn": "978-3-16-148410-0",
        "stockQuantity": 100
    }
}
```

### 2. Get All Books
- **Endpoint**: `GET /books`
- **Description**: Get list of all books
- **Query Parameters**:
  - `page` (optional): Page number
  - `limit` (optional): Items per page
  - `category` (optional): Filter by category
  - `search` (optional): Search in title/author
- **Response (200)**:
```json
{
    "books": [
        {
            "id": "book_id",
            "title": "The Great Book",
            "author": "John Author",
            "price": 29.99,
            "category": "Fiction"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 5,
        "totalItems": 100
    }
}
```

### 3. Get Book Details
- **Endpoint**: `GET /books/:id`
- **Description**: Get detailed information about a book
- **Response (200)**:
```json
{
    "book": {
        "id": "book_id",
        "title": "The Great Book",
        "author": "John Author",
        "description": "A wonderful book about...",
        "price": 29.99,
        "category": "Fiction",
        "isbn": "978-3-16-148410-0",
        "stockQuantity": 100,
        "reviews": [
            {
                "id": "review_id",
                "rating": 5,
                "comment": "Great book!",
                "user": {
                    "id": "user_id",
                    "username": "reviewer"
                }
            }
        ]
    }
}
```

### 4. Update Book (Admin Only)
- **Endpoint**: `PUT /books/:id`
- **Description**: Update book information
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Request Body**: (all fields optional)
```json
{
    "title": "Updated Title",
    "price": 39.99,
    "stockQuantity": 150
}
```
- **Response (200)**:
```json
{
    "message": "Book updated successfully",
    "book": {
        "id": "book_id",
        "title": "Updated Title",
        "price": 39.99,
        "stockQuantity": 150
    }
}
```

### 5. Delete Book (Admin Only)
- **Endpoint**: `DELETE /books/:id`
- **Description**: Delete a book
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Response (200)**:
```json
{
    "message": "Book deleted successfully"
}
```

## 🛒 Order Endpoints

### 1. Create Order
- **Endpoint**: `POST /orders`
- **Description**: Place a new order
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Request Body**:
```json
{
    "items": [
        {
            "bookId": "book_id",
            "quantity": 2
        }
    ],
    "shippingAddress": {
        "street": "123 Book St",
        "city": "Reading",
        "state": "CA",
        "zipCode": "12345"
    }
}
```
- **Response (201)**:
```json
{
    "message": "Order placed successfully",
    "order": {
        "id": "order_id",
        "items": [
            {
                "book": {
                    "id": "book_id",
                    "title": "The Great Book",
                    "price": 29.99
                },
                "quantity": 2,
                "subtotal": 59.98
            }
        ],
        "total": 59.98,
        "status": "pending",
        "shippingAddress": {
            "street": "123 Book St",
            "city": "Reading",
            "state": "CA",
            "zipCode": "12345"
        }
    }
}
```

### 2. Get User Orders
- **Endpoint**: `GET /orders`
- **Description**: Get list of user's orders
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Response (200)**:
```json
{
    "orders": [
        {
            "id": "order_id",
            "total": 59.98,
            "status": "pending",
            "createdAt": "2025-01-19T20:00:00.000Z"
        }
    ]
}
```

### 3. Get Order Details
- **Endpoint**: `GET /orders/:id`
- **Description**: Get detailed information about an order
- **Headers**: 
```
Authorization: Bearer jwt_token
```
- **Response (200)**:
```json
{
    "order": {
        "id": "order_id",
        "items": [
            {
                "book": {
                    "id": "book_id",
                    "title": "The Great Book",
                    "price": 29.99
                },
                "quantity": 2,
                "subtotal": 59.98
            }
        ],
        "total": 59.98,
        "status": "pending",
        "shippingAddress": {
            "street": "123 Book St",
            "city": "Reading",
            "state": "CA",
            "zipCode": "12345"
        },
        "createdAt": "2025-01-19T20:00:00.000Z"
    }
}
```

## Error Responses

All endpoints may return these error responses:

### 400 Bad Request
```json
{
    "error": "Validation Failed",
    "details": [
        {
            "msg": "Invalid email format",
            "param": "email",
            "location": "body"
        }
    ]
}
```

### 401 Unauthorized
```json
{
    "error": "UNAUTHORIZED",
    "message": "Please authenticate"
}
```

### 403 Forbidden
```json
{
    "error": "FORBIDDEN",
    "message": "Access denied"
}
```

### 404 Not Found
```json
{
    "error": "NOT_FOUND",
    "message": "Resource not found"
}
```

### 500 Server Error
```json
{
    "error": "SERVER_ERROR",
    "message": "Internal server error"
}
```

## Authentication
- All protected endpoints require a valid JWT token in the Authorization header
- Token format: `Bearer <token>`
- Tokens are obtained through login or email verification
- Tokens expire after the time specified in JWT_EXPIRATION env variable

## Rate Limiting
- API requests are limited to prevent abuse
- Rate limits are applied per IP address
- Exceeded rate limits return 429 Too Many Requests

## Best Practices
1. Always validate input before sending
2. Handle all possible error responses
3. Store tokens securely
4. Refresh tokens before expiry
5. Include error handling in your code
