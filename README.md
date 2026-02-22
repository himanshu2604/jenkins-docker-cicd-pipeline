# 🚀 DevOps CI/CD Pipeline - Abode Software

![DevOps](https://img.shields.io/badge/DevOps-Pipeline-blue)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

A complete **DevOps CI/CD pipeline** implementation featuring automated build, test, and deployment workflows with Docker containerization and Jenkins orchestration.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Pipeline Workflow](#pipeline-workflow)
- [Git Branching Strategy](#git-branching-strategy)
- [Screenshots](#screenshots)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

This project implements a **complete DevOps lifecycle** for Abode Software's web application, featuring:

- ✅ **Automated CI/CD Pipeline** with Jenkins
- ✅ **Docker Containerization** for consistent deployments
- ✅ **Configuration Management** using Ansible
- ✅ **Git Workflow** with branch-based deployment strategies
- ✅ **Automated Testing** with comprehensive test suites
- ✅ **Production-Ready** infrastructure setup

### Project Goals

- Implement DevOps best practices for rapid software delivery
- Automate build, test, and deployment processes
- Ensure code quality through automated testing
- Enable continuous integration and continuous deployment (CI/CD)

---

## 🏗️ Architecture

<img width="2126" height="822" alt="diagram-export-2-22-2026-11_11_38-AM" src="https://github.com/user-attachments/assets/0d881905-b8b7-4251-8164-d5cbf109f459" />

---

## ✨ Features

### 🔄 Automated CI/CD
- **Automatic triggering** on Git push via webhooks
- **Branch-based deployment** (master → production, develop → test only)
- **Pipeline stages**: Build → Test → Deploy
- **Rollback capability** for failed deployments

### 🐳 Docker Integration
- Containerized application for consistency across environments
- Uses `hshar/webapp` as base image
- Health checks and monitoring built-in
- Easy scaling and deployment

### 🧪 Automated Testing
- Container health verification
- HTTP endpoint testing
- Application availability checks
- Resource usage monitoring
- Log analysis for errors

### ⚙️ Configuration Management
- Ansible playbooks for environment setup
- Automated software installation (Docker, Git, Java, Maven)
- Idempotent configuration scripts
- Multi-platform support (Ubuntu/Debian)

### 📊 Monitoring & Logging
- Real-time build status in Jenkins
- Docker container logs
- Test result reporting
- Build history tracking

---

## 🛠️ Technologies Used

| Technology | Purpose | Version |
|------------|---------|---------|
| **Jenkins** | CI/CD orchestration | LTS |
| **Docker** | Containerization | 24.x |
| **Ansible** | Configuration management | 2.x |
| **Git/GitHub** | Version control | 2.x |
| **Bash** | Scripting & automation | 5.x |
| **Maven** | Build automation (optional) | 3.x |
| **Java** | Jenkins runtime | 11 |

---

## 📁 Project Structure

```
devops-capstone/
│
├── Jenkinsfile                 # Jenkins pipeline definition
├── Dockerfile                  # Docker container configuration
├── docker-compose.yml          # Multi-container orchestration
├── ansible-playbook.yml        # Environment setup automation
├── test.sh                     # Automated test script
│
├── docs/
│   ├── setup-guide.md          # Detailed setup instructions
│   ├── troubleshooting.md      # Common issues & solutions
│   └── windows-quickstart.md   # Windows-specific setup
│
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

---

## 🚀 Getting Started

### Prerequisites

- **Operating System**: Windows 10/11 Pro, Linux, or macOS
- **RAM**: Minimum 8GB
- **Disk Space**: At least 20GB free
- **Software**: 
  - Docker Desktop (Windows/Mac) or Docker Engine (Linux)
  - Git
  - Java 11 (for Jenkins)

### Installation Steps

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/himanshu2604/jenkins-devops-cicd-pipeline.git
cd jenkins-devops-cicd-pipeline
```

#### 2️⃣ Setup Environment (Using Ansible)

```bash
# Run the Ansible playbook to install dependencies
ansible-playbook ansible-playbook.yml
```

**OR** Install manually:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Jenkins (using Docker)
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

#### 3️⃣ Configure Jenkins

1. Access Jenkins at `http://localhost:8080`
2. Get initial password:
   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Install suggested plugins
4. Install additional plugins:
   - Docker Pipeline
   - Git Plugin
   - GitHub Integration Plugin

#### 4️⃣ Create Jenkins Pipeline

1. **New Item** → **Pipeline**
2. Name: `Abode-DevOps-Pipeline`
3. Configure:
   - **Build Triggers**: ✓ GitHub hook trigger for GITScm polling
   - **Pipeline**:
     - Definition: Pipeline script from SCM
     - SCM: Git
     - Repository URL: `https://github.com/himanshu2604/jenkins-devops-cicd-pipeline.git`
     - Branches: `*/master` and `*/develop`
     - Script Path: `Jenkinsfile`

#### 5️⃣ Setup GitHub Webhook

1. Go to your GitHub repository → **Settings** → **Webhooks**
2. Click **Add webhook**
3. Configure:
   - Payload URL: `http://YOUR_JENKINS_URL:8080/github-webhook/`
   - Content type: `application/json`
   - Events: Just the push event
   - Active: ✓

#### 6️⃣ Test the Pipeline

```bash
# Create develop branch
git checkout -b develop
git push origin develop

# Make a test commit
echo "<h1>Test Update</h1>" >> index.html
git add .
git commit -m "Test pipeline trigger"
git push origin develop
```

---

## 🔄 Pipeline Workflow

### Stage 1: Build 🔨
```
→ Checkout code from GitHub
→ Stop and remove existing containers
→ Build Docker image
→ Tag image with build number
```

### Stage 2: Test 🧪
```
→ Run container from built image
→ Wait for container to be ready
→ Execute automated tests:
   ├─ Container health check
   ├─ HTTP endpoint verification
   ├─ Application accessibility
   └─ Log analysis
```

### Stage 3: Deploy 🚀
```
IF branch == master:
   → Keep container running (PRODUCTION)
   → Application available on port 8081
   
IF branch == develop:
   → Stop and remove container (TEST ONLY)
   → No production deployment
```

---

## 🌿 Git Branching Strategy

### Master Branch (Production)
```bash
git checkout master
# Make changes
git add .
git commit -m "Production update"
git push origin master
```
**Result**: Build → Test → **Deploy to Production** ✅

### Develop Branch (Testing)
```bash
git checkout develop
# Make changes
git add .
git commit -m "Development update"
git push origin develop
```
**Result**: Build → Test → **Stop** (No Production Deployment) ⏹️

### Feature Branch Workflow
```bash
git checkout develop
git checkout -b feature/new-feature
# Develop feature
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
# Create Pull Request to develop
# After review → Merge to develop
# After testing → Merge develop to master
```

---

## 📸 Screenshots

### Jenkins Pipeline Success
```
╔════════════════════════════════════════╗
║   PIPELINE EXECUTED SUCCESSFULLY! ✓    ║
╚════════════════════════════════════════╝

Build Summary:
-------------
Build Number: #42
Branch: master
Status: SUCCESS
Deployment: PRODUCTION
URL: http://localhost:8081
```

### Test Results
```
========================================
Test Summary
========================================
Tests Passed: 7
Tests Failed: 0

╔════════════════════════════════════════╗
║   ALL TESTS PASSED SUCCESSFULLY! ✓     ║
╚════════════════════════════════════════╝
```

---

## 🔧 Configuration Files

### Jenkinsfile (Pipeline as Code)
```groovy
pipeline {
    agent any
    stages {
        stage('Build') { ... }
        stage('Test') { ... }
        stage('Deploy to Production') {
            when { branch 'master' }
            ...
        }
    }
}
```

### Dockerfile
```dockerfile
FROM hshar/webapp
WORKDIR /var/www/html
COPY . /var/www/html/
EXPOSE 8081
CMD ["apachectl", "-D", "FOREGROUND"]
```

### Test Script (test.sh)
```bash
#!/bin/bash
# Automated testing suite
# - Container health checks
# - HTTP endpoint verification
# - Application accessibility tests
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: Jenkins can't connect to Docker
```bash
# Solution: Add Jenkins to Docker group
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins
```

**Issue**: Port 81 already in use
```bash
# Solution: Use different port
docker run -d --name abode-webapp -p 8082:80 hshar/webapp:latest
```

**Issue**: Webhook not triggering
```bash
# Solution: Use ngrok for localhost
ngrok http 8080
# Use ngrok URL in GitHub webhook
```

For more solutions, see [Troubleshooting Guide](docs/troubleshooting.md)

---

## 📚 Documentation

- [Complete Setup Guide](docs/setup-guide.md)
- [Windows Quick Start](docs/windows-quickstart.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Pipeline Configuration](docs/pipeline-config.md)

---

## 🎓 Learning Outcomes

This project demonstrates proficiency in:

- ✅ CI/CD pipeline design and implementation
- ✅ Docker containerization and orchestration
- ✅ Jenkins configuration and automation
- ✅ Infrastructure as Code (IaC) with Ansible
- ✅ Git workflow and branching strategies
- ✅ Automated testing and quality assurance
- ✅ DevOps best practices and methodologies

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [Himasnhu2604](https://github.com/himanshu2604)
- LinkedIn: [Himanshu Nehete](www.linkedin.com/in/himanshu-nehete)
- Email: himanshunehete2025@gmail.com

---

## 🙏 Acknowledgments

- Intellipaat for the project requirements
- Jenkins community for excellent documentation
- Docker for containerization technology
- Ansible for automation capabilities

---

## 📊 Project Stats

![GitHub last commit](https://img.shields.io/github/last-commit/himanshu2604/devops-capstone)
![GitHub issues](https://img.shields.io/github/issues/himanshu2604/devops-capstone)
![GitHub pull requests](https://img.shields.io/github/issues-pr/himanshu2604/devops-capstone)
![GitHub stars](https://img.shields.io/github/stars/himanshu2604/devops-capstone?style=social)

---

<div align="center">

### ⭐ Star this repository if you found it helpful!

**Built with ❤️ using DevOps best practices**

[Report Bug](https://github.com/himanshu2604/devops-capstone/issues) • [Request Feature](https://github.com/himanshu2604/devops-capstone/issues)

</div>
