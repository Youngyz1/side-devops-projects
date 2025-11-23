  // For Monitoring#


const express = require('express');
const app = express();
const PORT = process.env.PORT || 3001;  // Using 3001 to avoid conflicts

// Track some basic metrics
let requestCount = 0;
let healthCheckCount = 0;
const startTime = Date.now();

// Middleware to count requests
app.use((req, res, next) => {
  requestCount++;
  next();
});

// Simple home page
app.get('/', (req, res) => {
  res.send(`
    <h1>🚀 My DevOps Web App</h1>
    <p>This app was deployed automatically!</p>
    <p>Current time: ${new Date().toLocaleString()}</p>
    <p>Total requests: ${requestCount}</p>
  `);
});

// Health check (important for deployment)
app.get('/health', (req, res) => {
  healthCheckCount++;
  res.json({ 
    status: 'healthy', 
    time: new Date(),
    uptime: process.uptime(),
    requests: requestCount
  });
});

// Metrics endpoint for Prometheus
app.get('/metrics', (req, res) => {
  const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);
  
  res.set('Content-Type', 'text/plain');
  res.send(`
# HELP youngyzapp_requests_total Total number of requests
# TYPE youngyzapp_requests_total counter
youngyzapp_requests_total ${requestCount}

# HELP youngyzapp_health_checks_total Total number of health checks
# TYPE youngyzapp_health_checks_total counter
youngyzapp_health_checks_total ${healthCheckCount}

# HELP youngyzapp_uptime_seconds Application uptime in seconds
# TYPE youngyzapp_uptime_seconds gauge
youngyzapp_uptime_seconds ${uptimeSeconds}

# HELP youngyzapp_process_uptime_seconds Process uptime in seconds
# TYPE youngyzapp_process_uptime_seconds gauge
youngyzapp_process_uptime_seconds ${process.uptime()}

# HELP youngyzapp_memory_usage_bytes Memory usage in bytes
# TYPE youngyzapp_memory_usage_bytes gauge
youngyzapp_memory_usage_bytes ${process.memoryUsage().heapUsed}

# HELP youngyzapp_up Application is running
# TYPE youngyzapp_up gauge
youngyzapp_up 1
  `);
});

app.listen(PORT, () => {
  console.log(`App running on port ${PORT}`);
  console.log(`Metrics available at http://localhost:${PORT}/metrics`);
});







// const express = require('express');
// const app = express();
// const PORT = process.env.PORT || 3001;  // Using 3001 to avoid conflicts

// // Simple home page
// app.get('/', (req, res) => {
//   res.send(`
//     <h1>🚀 My DevOps Web App</h1>
//     <p>This app was deployed automatically!</p>
//     <p>Current time: ${new Date().toLocaleString()}</p>
//   `);
// });

// // Health check (important for deployment)
// app.get('/health', (req, res) => {
//   res.json({ status: 'healthy', time: new Date() });
// });

// app.listen(PORT, () => {
//   console.log(`App running on port ${PORT}`);
// });