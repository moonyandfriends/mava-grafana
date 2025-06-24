# 📊 Mava Grafana - Railway Template

[![CI/CD Pipeline](https://github.com/moonyandfriends/mava-grafana/actions/workflows/ci.yml/badge.svg)](https://github.com/moonyandfriends/mava-grafana/actions/workflows/ci.yml)
[![Docker Build](https://img.shields.io/badge/docker-ready-blue.svg)](https://hub.docker.com)
[![Railway Deploy](https://img.shields.io/badge/deploy-railway-green.svg)](https://railway.app)

A production-ready Grafana template optimized for Railway deployment with prebuilt dashboards for support ticket analytics using Supabase (PostgreSQL).

## 🚀 Features

- **Railway-Optimized**: One-click deployment to Railway
- **Supabase Integration**: Pre-configured PostgreSQL datasource for Supabase
- **Support Ticket Analytics**: Purpose-built dashboards for Mava support system
- **Prebuilt Dashboards**: System monitoring, business metrics, and demo dashboards
- **Docker-Based**: Lightweight, containerized setup
- **Security**: Production-ready with proper authentication and RLS support

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Railway Deployment](#railway-deployment)
- [Local Development](#local-development)
- [Dashboard Overview](#dashboard-overview)
- [Configuration](#configuration)
- [Support Ticket Analytics](#support-ticket-analytics)
- [Customization](#customization)

## 🚀 Quick Start

### Railway Deployment (Recommended)

1. **Fork this repository**

2. **Deploy to Railway**
   - Connect your GitHub repository to Railway
   - Railway will automatically detect the `Dockerfile` and deploy

3. **Configure Environment Variables in Railway**
   ```env
   GRAFANA_ADMIN_USER=admin
   GRAFANA_ADMIN_PASSWORD=your-secure-password
   SUPABASE_URL=your-supabase-url
   SUPABASE_SERVICE_KEY=your-service-key
   ```

4. **Access Grafana**
   - Your Railway app URL will be provided after deployment
   - Login with your configured admin credentials

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mava-grafana.git
   cd mava-grafana
   ```

2. **Configure environment variables**
   ```bash
   cp env.example .env
   # Edit .env with your settings
   ```

3. **Start the services**
   ```bash
   # Grafana only
   docker-compose up -d

   # Or use the helper script
   chmod +x scripts/start.sh
   ./scripts/start.sh -d
   ```

## 🎯 Dashboard Overview

### Support Ticket Analytics
- **Ticket Volume Dashboard**: Track ticket creation trends and volume
- **Response Time Analytics**: Monitor agent response times and SLA compliance
- **Customer Satisfaction**: Visualize ratings and feedback trends
- **Agent Performance**: Track individual and team performance metrics
- **Resolution Analytics**: Monitor ticket resolution patterns and bottlenecks

### System Monitoring
- **Node Exporter Dashboard**: CPU, Memory, Disk, Network monitoring
- **Application Metrics**: Custom application performance metrics

### Demo Dashboards
- **TestData Demo**: Showcase various panel types and visualizations

## ⚙️ Configuration

### Supabase Setup

1. **Create a Supabase project** at [supabase.com](https://supabase.com)

2. **Get your connection details**:
   - Project URL: `https://your-project.supabase.co`
   - Service Role Key: Found in Project Settings > API

3. **Configure in Railway or .env**:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-role-key
   ```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GRAFANA_ADMIN_USER` | Grafana admin username | `admin` |
| `GRAFANA_ADMIN_PASSWORD` | Grafana admin password | `admin123!@#` |
| `GRAFANA_PORT` | Grafana port (local only) | `3000` |
| `SUPABASE_URL` | Your Supabase project URL | - |
| `SUPABASE_SERVICE_KEY` | Supabase service role key | - |

## 📊 Support Ticket Analytics

Based on your Mava database schema, the following dashboards are included:

### 1. Ticket Volume & Trends
- **Daily/Weekly/Monthly ticket volume**
- **Ticket creation trends by source type** (Discord, Web, etc.)
- **Peak support hours analysis**
- **Seasonal patterns and forecasting**

### 2. Response Time Analytics
```sql
-- Average first response time
SELECT 
  DATE_TRUNC('day', created_at) as day,
  AVG(EXTRACT(EPOCH FROM (first_agent_message_created_at - first_customer_message_created_at))/3600) as avg_response_hours
FROM tickets 
WHERE first_agent_message_created_at IS NOT NULL
GROUP BY day
ORDER BY day;
```

### 3. Status & Priority Distribution
- **Current ticket status breakdown**
- **Priority level distribution**
- **Status transition analysis**
- **SLA compliance tracking**

### 4. Customer Insights
- **Most active customers**
- **Customer satisfaction trends** (from user_ratings)
- **Customer resolution patterns**
- **Discord role analysis**

### 5. Agent Performance
- **Tickets handled per agent**
- **Average resolution time by agent**
- **Agent workload distribution**
- **Response time by agent**

### 6. AI Integration Metrics
- **AI-enabled vs manual ticket handling**
- **AI success rates**
- **Human takeover patterns**
- **Automation effectiveness**

## 🔧 Railway Configuration

### Dockerfile for Railway
The included `Dockerfile` is optimized for Railway deployment:

- Multi-stage build for smaller image size
- Proper health checks
- Security best practices
- Environment variable configuration

### Railway-Specific Features
- **Automatic HTTPS**: Railway provides SSL certificates
- **Custom Domains**: Configure your own domain
- **Environment Management**: Easy variable management
- **Automatic Deployments**: Git-based deployments
- **Scaling**: Horizontal scaling support

## 🎨 Customization

### Adding New Dashboards

1. **Create dashboard JSON files** in appropriate folders:
   ```
   grafana/dashboards/
   ├── general/       # General purpose dashboards
   ├── system/        # System monitoring
   ├── application/   # Application metrics
   ├── business/      # Business analytics
   └── demo/          # Demo dashboards
   ```

2. **Update provisioning configuration** in `grafana/provisioning/dashboards/dashboards.yml`

### Adding Data Sources

1. **Configure in** `grafana/provisioning/datasources/datasources.yml`
2. **Add environment variables** for sensitive data
3. **Update docker-compose.yml** if needed

### Custom Queries for Support Tickets

```sql
-- Ticket resolution time by priority
SELECT 
  priority,
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/3600) as avg_resolution_hours
FROM tickets 
WHERE status = 'closed'
GROUP BY priority;

-- Customer satisfaction by agent
SELECT 
  t.assigned_to,
  AVG((c.user_ratings->0->>'rating')::numeric) as avg_rating
FROM tickets t
JOIN customers c ON t.customer_id = c.id
WHERE c.user_ratings != '[]'::jsonb
GROUP BY t.assigned_to;

-- AI vs Human handling success
SELECT 
  CASE WHEN ai_status IS NOT NULL THEN 'AI' ELSE 'Human' END as handler_type,
  COUNT(*) as ticket_count,
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/3600) as avg_resolution_hours
FROM tickets
WHERE status = 'closed'
GROUP BY handler_type;
```

## 🚀 Deployment Steps

### Railway Deployment

1. **Fork this repository**
2. **Create Railway account**
3. **Connect GitHub repository**
4. **Configure environment variables**:
   - `GRAFANA_ADMIN_PASSWORD`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`
5. **Deploy**

### Manual Deployment

```bash
# Build and push to your registry
docker build -t your-registry/mava-grafana .
docker push your-registry/mava-grafana

# Deploy to your platform
# (Railway, Heroku, DigitalOcean, etc.)
```

## 🔒 Security

- **Environment Variables**: Sensitive data stored securely
- **RLS Support**: Compatible with Supabase Row Level Security
- **HTTPS**: SSL/TLS encryption in production
- **Authentication**: Configurable admin credentials
- **Network Security**: Docker network isolation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Railway Support**: [Railway Documentation](https://docs.railway.app)
- **Grafana Documentation**: [Grafana Docs](https://grafana.com/docs/)

## 🔗 Related Links

- [Railway](https://railway.app)
- [Supabase](https://supabase.com)
- [Grafana](https://grafana.com)
- [Docker](https://docker.com)