# DevOps CI/CD Pipeline - Setup Guide

## Prerequisites

- Windows 10/11 Pro or Linux
- Docker Desktop installed
- Jenkins installed
- Git installed
- 8GB RAM minimum

---

## Quick Setup (5 Steps)

### Step 1: Install Software

**Docker Desktop:**
```bash
# Download from: https://www.docker.com/products/docker-desktop
# Verify:
docker --version
```

**Jenkins:**
```bash
# Using Docker (recommended):
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Get initial password:
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Step 2: Configure Jenkins

1. Open: http://localhost:8080
2. Enter initial password
3. Install suggested plugins
4. Install additional plugins:
   - Docker Pipeline
   - Git Plugin
   - GitHub Integration

### Step 3: Clone Project

```bash
git clone https://github.com/himanshu2604/jenkins-docker-cicd-pipeline.git
cd jenkins-docker-cicd-pipeline
```

### Step 4: Create Jenkins Pipeline

1. Jenkins → New Item → Pipeline
2. Name: `Abode-DevOps-Pipeline`
3. Configure:
   - Build Triggers: ✓ GitHub hook trigger
   - Pipeline from SCM: Git
   - Repository: `https://github.com/himanshu2604/jenkins-docker-cicd-pipeline.git`
   - Branches: `*/master` and `*/develop`
   - Script Path: `Jenkinsfile`
4. Save

### Step 5: Run Pipeline

1. Click "Build Now"
2. Wait for build to complete
3. Access application: http://localhost:8081

---

## Verify Installation

```bash
# Check Docker
docker ps

# Check Jenkins
curl http://localhost:8080

# Check Application
curl http://localhost:8081
```

---

## File Structure

```
project/
├── Dockerfile          # Docker configuration
├── Jenkinsfile        # Pipeline definition
├── index.html         # Application file
├── test.sh           # Test script
└── docker-compose.yml # Optional
```

---

## Environment Variables

Update in `Jenkinsfile`:
```groovy
environment {
    DOCKER_IMAGE = "hshar/webapp"
    CONTAINER_NAME = "abode-webapp"
    APP_PORT = "8081"
}
```

---

## Branch Workflow

**Master Branch:**
```bash
git checkout master
git add .
git commit -m "Update"
git push
# Result: Build → Test → Deploy to Production
```

**Develop Branch:**
```bash
git checkout develop
git add .
git commit -m "Update"
git push
# Result: Build → Test → Cleanup (no deployment)
```

---

## Common Issues

### Jenkins can't access Docker
```bash
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins
```

### Port already in use
```bash
# Windows
netstat -ano | findstr :8081
taskkill /PID <PID> /F

# Linux
sudo lsof -i :8081
sudo kill -9 <PID>
```

### Build fails
```bash
# Check Docker
docker ps

# Check Dockerfile exists
ls Dockerfile

# View Jenkins logs
docker logs jenkins
```

---

## Access Points

| Service | URL | Port |
|---------|-----|------|
| Jenkins | http://localhost:8080 | 8080 |
| Application | http://localhost:8081 | 8081 |

---

## Next Steps

1. ✅ Setup complete
2. Configure GitHub webhook (optional)
3. Add SCM polling: `H/5 * * * *`
4. Customize Jenkinsfile as needed
5. Update index.html with your content

---

## Support

- Check logs: `docker logs <container-name>`
- View Jenkins console output
- Refer to troubleshooting-guide.md

---

**Setup Time: ~15 minutes**  
**Difficulty: Intermediate**

For detailed instructions, see the full documentation in the repository.
