const express = require('express');
const client = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3001;

// Create a Prometheus Registry
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// /metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err);
  }
});

// Simple home page
app.get('/', (req, res) => {
  res.send(`
    <h1>🚀 Youngyz AWS DevOps Web App</h1>
    <p>This app was deployed automatically to AWS ECS!</p>
    <p>Environment: ${process.env.ENVIRONMENT || 'development'}</p>
    <p>Current time: ${new Date().toLocaleString()}</p>
    <p>Container ID: ${require('os').hostname()}</p>
  `);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    time: new Date(),
    environment: process.env.ENVIRONMENT || 'development'
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'my-aws-youngyzapp',
    version: '1.0.0',
    environment: process.env.ENVIRONMENT || 'development',
    timestamp: new Date()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`App running on port ${PORT}`);
  console.log(`Environment: ${process.env.ENVIRONMENT || 'development'}`);
});
