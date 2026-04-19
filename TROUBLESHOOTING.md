# Login Troubleshooting Guide

## Most Common Issue: Backend Server Not Running

The login feature requires the backend server to be running. Here's how to fix it:

### Step 1: Start the Backend Server

```bash
cd backend
npm install
npm start
```

You should see:
```
Backend server running on http://localhost:3000

Available endpoints:

Authentication:
  POST   /api/auth/signup
  POST   /api/auth/login
  GET    /api/auth/verify
  POST   /api/auth/logout
...
```

### Step 2: Test the Connection

Run the Flutter app and try to sign up with a new account first (not login):
- Email: test@example.com
- Password: test123
- Name: Test User

If signup works, then login with the same credentials.

### Step 3: Common Issues

#### Issue: "Connection error: SocketException"
**Solution:** Backend server is not running. Start it with `npm start` in the backend folder.

#### Issue: "Connection error: Connection refused"
**Solution:** 
- Make sure backend is running on port 3000
- Check if another app is using port 3000
- Try restarting the backend server

#### Issue: "Invalid credentials"
**Solution:** 
- You need to sign up first before logging in
- The backend uses in-memory storage, so data is lost when server restarts
- Make sure you're using the correct email/password

#### Issue: iOS Simulator - "Connection refused"
**Solution:** iOS simulator needs special configuration for localhost:
1. Use `http://127.0.0.1:3000` instead of `http://localhost:3000`
2. Or update Info.plist to allow localhost connections

### Step 4: Update Backend URL for iOS (if needed)

If you're testing on iOS simulator, update the auth service:

In `lib/services/auth_service.dart`, change:
```dart
static const String baseUrl = 'http://localhost:3000/api/auth';
```

To:
```dart
static const String baseUrl = 'http://127.0.0.1:3000/api/auth';
```

Do the same for:
- `lib/services/expense_service.dart`
- `lib/services/budget_service.dart`
- `lib/services/settings_service.dart`

### Step 5: Verify Backend is Working

Test the backend directly with curl:

```bash
# Test signup
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","name":"Test User"}'

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

Both should return a JSON response with a token.

## Quick Checklist

- [ ] Backend server is running (`npm start` in backend folder)
- [ ] Backend shows "Backend server running on http://localhost:3000"
- [ ] First time users must SIGN UP before logging in
- [ ] Using correct email/password (backend data is lost on restart)
- [ ] If on iOS, using 127.0.0.1 instead of localhost

## Still Not Working?

Check the Flutter console for the exact error message. The error will tell you:
- "Connection error" = Backend not running
- "Invalid credentials" = Wrong email/password or user doesn't exist
- "User already exists" = Try logging in instead of signing up
