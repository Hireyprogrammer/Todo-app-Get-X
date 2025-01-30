# Book Store REST API Guide

## Base URL
When deployed, replace `localhost:5000` with your actual deployed domain.
Base URL: `http://localhost:5000/api`

## Authentication Endpoints
### User Registration
- **URL**: `/auth/register`
- **Method**: `POST`
- **Request Body**:
```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```
- **Success Response**: 
  - **Code**: 201 Created
  - **Content**: User details without password

### User Login
- **URL**: `/auth/login`
- **Method**: `POST`
- **Request Body**:
```json
{
  "email": "string",
  "password": "string"
}
```
- **Success Response**:
  - **Code**: 200 OK
  - **Content**: 
    ```json
    {
      "token": "jwt_token_here",
      "user": {
        "id": "user_id",
        "username": "johndoe",
        "email": "john@example.com"
      }
    }
    ```

### Verify Email
- **URL**: `/auth/verify`
- **Method**: `POST`
- **Request Body**:
```json
{
  "email": "string",
  "code": "string"
}
```
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: Verification result

### Reset Password
- **URL**: `/auth/reset-password`
- **Method**: `POST`
- **Request Body**:
```json
{
  "email": "string"
}
```
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: Password reset result

### Get Profile
- **URL**: `/auth/profile`
- **Method**: `GET`
- **Authorization**: Required (Bearer token)
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: User profile details

### Update Profile
- **URL**: `/auth/profile`
- **Method**: `PUT`
- **Authorization**: Required (Bearer token)
- **Request Body**:
```json
{
  "username": "string",
  "email": "string"
}
```
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: Updated user profile details

## Todo Endpoints
### Create Todo
- **URL**: `/todos`
- **Method**: `POST`
- **Authorization**: Required (Bearer token)
- **Request Body**:
```json
{
  "title": "string",
  "description": "string"
}
```
- **Success Response**: 
  - **Code**: 201 Created
  - **Content**: Created todo details

### Get All Todos
- **URL**: `/todos`
- **Method**: `GET`
- **Authorization**: Required (Bearer token)
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: List of todo details

### Get Todo by ID
- **URL**: `/todos/:id`
- **Method**: `GET`
- **Authorization**: Required (Bearer token)
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: Todo details

### Update Todo
- **URL**: `/todos/:id`
- **Method**: `PUT`
- **Authorization**: Required (Bearer token)
- **Request Body**:
```json
{
  "title": "string",
  "description": "string"
}
```
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: Updated todo details

### Delete Todo
- **URL**: `/todos/:id`
- **Method**: `DELETE`
- **Authorization**: Required (Bearer token)
- **Success Response**: 
  - **Code**: 200 OK
  - **Content**: Deletion result

## Error Handling
Standard Error Response Format:
```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "field": "field_name",
      "message": "error description"
    }
  ]
}
```

## Best Practices
1. Always use HTTPS
2. Include Authorization header for protected routes
3. Handle errors gracefully
4. Use proper status codes

## Security
- Use JWT for authentication
- Implement role-based access control
- Validate and sanitize all input
- Use HTTPS
- Implement rate limiting

## Rate Limiting

- 100 requests per IP per 15 minutes for public endpoints
- 1000 requests per IP per 15 minutes for authenticated endpoints

## Status Codes

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 429: Too Many Requests
- 500: Internal Server Error
