# Expense Tracker Backend Server

A comprehensive Node.js/Express backend for handling authentication, expenses, budgets, and settings.

## Setup

1. Install dependencies:

```bash
npm install
```

2. Start the server:

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

The server will run on `http://localhost:3000`

## API Endpoints

### Authentication

#### POST /api/auth/signup

Create a new user account.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response:**

```json
{
  "message": "User created successfully",
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### POST /api/auth/login

Login with existing credentials.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "message": "Login successful",
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### GET /api/auth/verify

Verify JWT token validity.

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "valid": true,
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### POST /api/auth/logout

Logout (client-side token removal).

**Response:**

```json
{
  "message": "Logout successful"
}
```

---

### Expenses

All expense endpoints require authentication via Bearer token.

#### GET /api/expenses

Get all expenses for the authenticated user.

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "expenses": [
    {
      "id": "expense_id",
      "title": "Grocery Shopping",
      "amount": 50.0,
      "category": "food",
      "date": "2024-01-15T10:30:00.000Z",
      "note": "Weekly groceries",
      "userId": "user_id",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

#### POST /api/expenses

Create a new expense.

**Headers:**

```
Authorization: Bearer <token>
```

**Request Body:**

```json
{
  "id": "unique_expense_id",
  "title": "Grocery Shopping",
  "amount": 50.0,
  "category": "food",
  "date": "2024-01-15T10:30:00.000Z",
  "note": "Weekly groceries"
}
```

**Response:**

```json
{
  "message": "Expense created",
  "expense": {
    /* expense object */
  }
}
```

#### PUT /api/expenses/:id

Update an existing expense.

**Headers:**

```
Authorization: Bearer <token>
```

**Request Body:**

```json
{
  "title": "Updated Title",
  "amount": 60.0,
  "category": "food",
  "date": "2024-01-15T10:30:00.000Z",
  "note": "Updated note"
}
```

**Response:**

```json
{
  "message": "Expense updated",
  "expense": {
    /* updated expense object */
  }
}
```

#### DELETE /api/expenses/:id

Delete a specific expense.

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "message": "Expense deleted"
}
```

#### DELETE /api/expenses

Delete all expenses for the authenticated user.

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "message": "All expenses deleted"
}
```

---

### Budget

#### GET /api/budget

Get the monthly budget for the authenticated user.

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "monthlyBudget": 5000.0,
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

#### PUT /api/budget

Update the monthly budget.

**Headers:**

```
Authorization: Bearer <token>
```

**Request Body:**

```json
{
  "monthlyBudget": 6000.0
}
```

**Response:**

```json
{
  "message": "Budget updated",
  "budget": {
    "monthlyBudget": 6000.0,
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

---

### Settings

#### GET /api/settings

Get user settings.

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "themeMode": "system",
  "currency": "USD",
  "currencySymbol": "$"
}
```

#### PUT /api/settings

Update user settings.

**Headers:**

```
Authorization: Bearer <token>
```

**Request Body:**

```json
{
  "themeMode": "dark",
  "currency": "EUR",
  "currencySymbol": "€"
}
```

**Response:**

```json
{
  "message": "Settings updated",
  "settings": {
    "themeMode": "dark",
    "currency": "EUR",
    "currencySymbol": "€",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

---

### Data Export

#### GET /api/export

Export all user data (expenses, budget, settings).

**Headers:**

```
Authorization: Bearer <token>
```

**Response:**

```json
{
  "expenses": [
    /* array of expenses */
  ],
  "budget": {
    /* budget object */
  },
  "settings": {
    /* settings object */
  },
  "exportedAt": "2024-01-15T10:30:00.000Z"
}
```

---

## Categories

Valid expense categories:

- `food`
- `transport`
- `shopping`
- `entertainment`
- `bills`
- `health`
- `education`
- `other`

## Theme Modes

Valid theme modes:

- `light`
- `dark`
- `system`

## Note

This is a simple in-memory implementation for development. In production:

- Use a proper database (MongoDB, PostgreSQL, etc.)
- Implement secure password hashing (bcrypt)
- Add input validation and sanitization
- Implement rate limiting
- Use environment variables for secrets
- Add proper error handling and logging
