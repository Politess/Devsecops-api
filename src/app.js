const express = require('express');

const app = express();
app.use(express.json());

// Health check — used by ECS to verify the container is alive
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Items resource — simple in-memory store (swap for a DB later)
let items = [
  { id: 1, name: 'Widget A', qty: 10 },
  { id: 2, name: 'Widget B', qty: 5 },
];

app.get('/items', (req, res) => {
  res.json(items);
});

app.get('/items/:id', (req, res) => {
  const item = items.find(i => i.id === parseInt(req.params.id));
  if (!item) return res.status(404).json({ error: 'Item not found' });
  res.json(item);
});

app.post('/items', (req, res) => {
  const { name, qty } = req.body;
  if (!name || qty === undefined) {
    return res.status(400).json({ error: 'name and qty are required' });
  }
  const newItem = { id: items.length + 1, name, qty };
  items.push(newItem);
  res.status(201).json(newItem);
});

module.exports = app;
