**This project sets up professional-grade monitoring for your applications using Prometheus, Grafana, and AlertManager, with system and container metrics collected via Node Exporter and cAdvisor, plus Slack notifications for alerts.**

## 1. Architecture Overview

Your App → Prometheus → Grafana → Dashboards & Alerts
↓           ↓
System & Container Metrics → Alerts → Slack Notifications

Components:

| Component | Purpose | Default Port |
| --- | --- | --- |
| Prometheus | Metrics collection | 9090 |
| Grafana | Dashboards & visualizations | 3000 |
| Node Exporter | System metrics (CPU, memory, disk) | 9100 |
| cAdvisor | Container metrics | 8080 |
| AlertManager | Alert routing and notifications | 9093 |

## 2. Prerequisites

- Docker Desktop
- Node.js application (optional, from previous projects)
- Web browser

## 3. Start Monitoring Stack

1. docker-compose up -d: this will start all monitoring services such as Prometheus, Grafana, Node Exporter, cAdvisor AlertManager.
2. docker-compose ps:   This will check all services if they have started and running.

## 4. Access Services

- **Prometheus**: [http://localhost:9090](http://localhost:9090/)
- **Grafana**: [http://localhost:3000](http://localhost:3000/) (Login: `admin` / `admin`)
- **Node Exporter**: http://localhost:9100/metrics
- **cAdvisor**: [http://localhost:8080](http://localhost:8080/)
- **AlertManager**: http://localhost:9093
1. 

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/1d629022-72fb-4796-baac-f8ad70ea9c70" />

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/7faf8df0-3943-40c2-9ce7-c912c419d625" />

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/a3933384-fe46-437c-9588-9d9aa185e199" />

## 5. Configure Grafana

1. Go to **Settings → Data Sources → Add Data Source**
2. Choose **Prometheus**
3. URL: `http://prometheus:9090`
4. Click **Save & Test**

## 6. Create Dashboards

**Option 1: Import pre-built**

1. Click `+ → Import`
2. Enter Dashboard ID: `1860` (Node Exporter Full)
3. Select **Prometheus** as data source
4. Click **Import**

**Option 2: Custom Panel**

1. Click `+ → Dashboard → Add Panel`
2. Query: `up`
3. Click **Apply** → **Save**

## 6. Monitor Your Application

Start your app:

On your application Folder Bash: npm start

Check Prometheus Targets: http://localhost:9090/targets

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/6a8abe03-6557-4c73-93d0-bcb9f3a8570c" />

## 7. Alert Rules

Create a file and name is `alert_rules.yml`

groups:

- name: youngyzapp_alerts
rules:
    - alert: AppIsDown
    expr: up{job="my-youngyzapp-local"} == 0
    for: 30s
    labels:
    severity: critical
    annotations:
    summary: "Your Node app is DOWN"
    description: "Prometheus cannot reach my-youngyzapp-local on port 3001."
    - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
    for: 2m
    labels:
    severity: warning
    annotations:
    summary: "High CPU usage"
    description: "Node exporter reports CPU usage > 80%."
1. This rules tell Prometheus when something is wrong and when to fire an alert.
2. Invoke-WebRequest -Uri http://localhost:9090/-/reload -Method POST

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/e66097af-64dd-4d6e-84ba-d0e7acc4d8d0" />

Restart AlertManager after update:

```bash
docker-compose restart alertmanager

Test Slack integration:
```

```powershell
Invoke-RestMethod -Uri "https://hooks.slack.com/services/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" `
-Method Post -Body '{"text":"Test alert from Alertmanager"}' -ContentType "application/json"

```

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/4f22eb9a-dd73-4b78-9883-7d728a4d26b2" />

## 8. Clean Up

```bash
# Stop and remove containers
docker-compose down

# Remove volumes
docker-compose down -v

# Remove unused images
docker image prune 
docker ps -a
```

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/8d351d67-6f36-46df-926b-ba4e18e7efb1" />

## 9. Troubleshooting

- No data in Grafana → Check Prometheus targets (`Status → Targets`)
- Missing app metrics → Run `curl http://localhost:3001/metrics`
- Alerts not firing → Check Prometheus alert rules and AlertManager logs:

**This documentation covers all steps, commands, and configs used in Project 4.**
