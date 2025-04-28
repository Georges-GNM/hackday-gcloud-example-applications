const functions = require('@google-cloud/functions-framework');
const express = require('express');
const fs = require('fs');
const path = require('path');

// Read application name from APPLICATION_NAME file
// this keeps it in sync with the deploy script
const applicationName = fs.readFileSync(path.join(__dirname, '../APP_NAME'), 'utf-8').trim();

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
functions.http(applicationName, app);
