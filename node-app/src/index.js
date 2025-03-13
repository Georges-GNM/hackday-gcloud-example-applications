const functions = require('@google-cloud/functions-framework');
const express = require('express');

// Create Express app
const app = express();

// Define routes
app.get('/', (req, res) => {
  res.send('OK');
});

app.get('/hello/world', (req, res) => {
  const name = req.query.name || 'World';
  res.send(`Hello, ${name}!`);
});

app.get('/users', (req, res) => {
  res.json([
    { id: 1, name: 'John Doe' },
    { id: 2, name: 'Jane Smith' },
    { id: 3, name: 'Bob Johnson' }
  ]);
});

// Connect our Express app to Google's Functions Framework
functions.http('node-hello-world', app); // must match target in package.json's npm run start
