const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const jwt = require("jsonwebtoken");

const app = express();
const PORT = 3000;
const SECRET_KEY = "your-secret-key-change-in-production";

app.use(cors());
app.use(bodyParser.json());

// Logging middleware - prints all incoming requests
app.use((req, res, next) => {
  console.log("\n========================================");
  console.log(`📥 ${req.method} ${req.url}`);
  console.log("⏰ Time:", new Date().toLocaleString());
  console.log("📋 Headers:", JSON.stringify(req.headers, null, 2));
  if (req.body && Object.keys(req.body).length > 0) {
    console.log("📦 Body:", JSON.stringify(req.body, null, 2));
  }
  console.log("========================================\n");
  next();
});

const users = new Map();
const userExpenses = new Map();
const userBudgets = new Map();
const userSettings = new Map();

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "No token provided" });
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    req.userId = decoded.id;
    req.userEmail = decoded.email;
    next();
  } catch (error) {
    res.status(401).json({ error: "Invalid token" });
  }
};

app.post("/api/auth/signup", (req, res) => {
  const { email, password, name } = req.body;

  if (!email || !password || !name) {
    return res.status(400).json({ error: "All fields are required" });
  }

  if (users.has(email)) {
    return res.status(409).json({ error: "User already exists" });
  }

  const user = {
    id: Date.now().toString(),
    email,
    password,
    name,
    createdAt: new Date().toISOString(),
  };

  users.set(email, user);

  const token = jwt.sign({ id: user.id, email: user.email }, SECRET_KEY, {
    expiresIn: "7d",
  });

  res.status(201).json({
    message: "User created successfully",
    token,
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
    },
  });
});

app.post("/api/auth/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email and password are required" });
  }

  const user = users.get(email);

  if (!user || user.password !== password) {
    return res.status(401).json({ error: "Invalid credentials" });
  }

  const token = jwt.sign({ id: user.id, email: user.email }, SECRET_KEY, {
    expiresIn: "7d",
  });

  res.json({
    message: "Login successful",
    token,
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
    },
  });
});

app.get("/api/auth/verify", (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "No token provided" });
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    const user = Array.from(users.values()).find((u) => u.id === decoded.id);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({
      valid: true,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    res.status(401).json({ error: "Invalid token" });
  }
});

app.post("/api/auth/logout", (req, res) => {
  res.json({ message: "Logout successful" });
});

app.get("/api/expenses", authenticateToken, (req, res) => {
  const expenses = userExpenses.get(req.userId) || [];
  res.json({ expenses });
});

app.post("/api/expenses", authenticateToken, (req, res) => {
  const { id, title, amount, category, date, note } = req.body;

  if (!id || !title || amount === undefined || !category || !date) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const expense = {
    id,
    title,
    amount,
    category,
    date,
    note: note || "",
    userId: req.userId,
    createdAt: new Date().toISOString(),
  };

  const expenses = userExpenses.get(req.userId) || [];
  expenses.push(expense);
  userExpenses.set(req.userId, expenses);

  res.status(201).json({ message: "Expense created", expense });
});

app.put("/api/expenses/:id", authenticateToken, (req, res) => {
  const { id } = req.params;
  const { title, amount, category, date, note } = req.body;

  const expenses = userExpenses.get(req.userId) || [];
  const index = expenses.findIndex((e) => e.id === id);

  if (index === -1) {
    return res.status(404).json({ error: "Expense not found" });
  }

  expenses[index] = {
    ...expenses[index],
    title,
    amount,
    category,
    date,
    note: note || "",
    updatedAt: new Date().toISOString(),
  };

  userExpenses.set(req.userId, expenses);
  res.json({ message: "Expense updated", expense: expenses[index] });
});

app.delete("/api/expenses/:id", authenticateToken, (req, res) => {
  const { id } = req.params;
  const expenses = userExpenses.get(req.userId) || [];
  const filtered = expenses.filter((e) => e.id !== id);

  if (expenses.length === filtered.length) {
    return res.status(404).json({ error: "Expense not found" });
  }

  userExpenses.set(req.userId, filtered);
  res.json({ message: "Expense deleted" });
});

app.delete("/api/expenses", authenticateToken, (req, res) => {
  userExpenses.set(req.userId, []);
  res.json({ message: "All expenses deleted" });
});

app.get("/api/budget", authenticateToken, (req, res) => {
  const budget = userBudgets.get(req.userId) || { monthlyBudget: 5000.0 };
  res.json(budget);
});

app.put("/api/budget", authenticateToken, (req, res) => {
  const { monthlyBudget } = req.body;

  if (monthlyBudget === undefined || monthlyBudget < 0) {
    return res.status(400).json({ error: "Invalid budget value" });
  }

  const budget = {
    monthlyBudget,
    updatedAt: new Date().toISOString(),
  };

  userBudgets.set(req.userId, budget);
  res.json({ message: "Budget updated", budget });
});

app.get("/api/settings", authenticateToken, (req, res) => {
  const settings = userSettings.get(req.userId) || {
    themeMode: "system",
    currency: "USD",
    currencySymbol: "$",
  };
  res.json(settings);
});

app.put("/api/settings", authenticateToken, (req, res) => {
  const { themeMode, currency, currencySymbol } = req.body;

  const settings = {
    themeMode: themeMode || "system",
    currency: currency || "USD",
    currencySymbol: currencySymbol || "$",
    updatedAt: new Date().toISOString(),
  };

  userSettings.set(req.userId, settings);
  res.json({ message: "Settings updated", settings });
});

app.get("/api/export", authenticateToken, (req, res) => {
  const expenses = userExpenses.get(req.userId) || [];
  const budget = userBudgets.get(req.userId) || { monthlyBudget: 5000.0 };
  const settings = userSettings.get(req.userId) || {};

  const exportData = {
    expenses,
    budget,
    settings,
    exportedAt: new Date().toISOString(),
  };

  res.json(exportData);
});

app.listen(PORT, () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
  console.log("\nAvailable endpoints:");
  console.log("\nAuthentication:");
  console.log("  POST   /api/auth/signup");
  console.log("  POST   /api/auth/login");
  console.log("  GET    /api/auth/verify");
  console.log("  POST   /api/auth/logout");
  console.log("\nExpenses:");
  console.log("  GET    /api/expenses");
  console.log("  POST   /api/expenses");
  console.log("  PUT    /api/expenses/:id");
  console.log("  DELETE /api/expenses/:id");
  console.log("  DELETE /api/expenses");
  console.log("\nBudget:");
  console.log("  GET    /api/budget");
  console.log("  PUT    /api/budget");
  console.log("\nSettings:");
  console.log("  GET    /api/settings");
  console.log("  PUT    /api/settings");
  console.log("\nData:");
  console.log("  GET    /api/export");
});
