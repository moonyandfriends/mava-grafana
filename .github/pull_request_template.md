## 📋 Pull Request Checklist

### 🔍 Changes Made
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Configuration change

### 📝 Description
Brief description of what this PR does:

### 🧪 Testing
- [ ] I have tested these changes locally
- [ ] Docker build passes (`docker build -t test .`)
- [ ] Docker Compose works (`docker-compose up -d`)
- [ ] All JSON/YAML files are valid
- [ ] CI pipeline passes

### 📚 Documentation
- [ ] I have updated the README.md if needed
- [ ] I have updated DEPLOYMENT.md if needed
- [ ] I have added/updated comments in complex code sections

### 🔒 Security
- [ ] No sensitive information (passwords, keys, etc.) is hardcoded
- [ ] Environment variables are properly configured
- [ ] No security vulnerabilities introduced

### ⚙️ Configuration Files
If you modified configuration files, please confirm:
- [ ] Grafana dashboards are valid JSON
- [ ] Datasource configurations are correct
- [ ] Environment variables are documented in env.example

### 🚀 Railway Deployment
If this affects Railway deployment:
- [ ] railway.json is properly configured
- [ ] Health checks are working
- [ ] Environment variables are set correctly

### 📊 Dashboard Changes
If you modified dashboards:
- [ ] Dashboard JSON is valid
- [ ] Panels have proper data sources configured
- [ ] Queries are optimized
- [ ] Dashboard is responsive

---

**Additional Notes:**
Add any additional context, screenshots, or information that reviewers should know about. 