# DevOps Capstone - Windows Quick Start Guide

## Prerequisites Checklist

Before starting, ensure you have:
- [ ] Windows 10/11 Pro, Enterprise, or Education
- [ ] Administrator access
- [ ] At least 8GB RAM
- [ ] At least 20GB free disk space
- [ ] Internet connection

---

## Quick Setup Commands

### Step 1: Install Chocolatey (Package Manager for Windows)

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Step 2: Install Required Software

```powershell
# Install Git
choco install git -y

# Install Java (required for Jenkins)
choco install openjdk11 -y

# Install Docker Desktop
choco install docker-desktop -y

# Install Visual Studio Code (optional)
choco install vscode -y
```

### Step 3: Enable WSL 2 (Required for Docker)

```powershell
# Enable WSL
wsl --install

# Set WSL 2 as default
wsl --set-default-version 2

# Install Ubuntu (will be used for Ansible)
wsl --install -d Ubuntu
```

**Restart your computer after this step**

### Step 4: Configure Ubuntu in WSL

Open Ubuntu from Start Menu and run:

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Install Ansible
sudo apt install ansible -y

# Install Python and pip
sudo apt install python3 python3-pip -y

# Verify installations
ansible --version
python3 --version
```

### Step 5: Start Docker Desktop

1. Open Docker Desktop from Start Menu
2. Wait for Docker to start (whale icon in system tray)
3. In Docker Desktop settings:
   - Go to Settings → Resources → WSL Integration
   - Enable integration with Ubuntu
   - Click "Apply & Restart"

### Step 6: Verify Docker Installation

Open PowerShell or Command Prompt:

```powershell
docker --version
docker run hello-world
```

You should see a success message.

### Step 7: Install Jenkins using Docker

```powershell
# Create a volume for Jenkins data
docker volume create jenkins_home

# Run Jenkins container
docker run -d `
  --name jenkins `
  -p 8080:8080 `
  -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  -v /var/run/docker.sock:/var/run/docker.sock `
  --restart unless-stopped `
  jenkins/jenkins:lts

# Wait 30 seconds for Jenkins to start, then get the initial password
Start-Sleep -Seconds 30
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy the password that appears!

### Step 8: Access Jenkins

1. Open browser: http://localhost:8080
2. Paste the password from previous step
3. Click "Install suggested plugins"
4. Wait for plugins to install
5. Create your admin user
6. Click "Save and Continue" → "Start using Jenkins"

### Step 9: Install Jenkins Plugins

In Jenkins:
1. Go to "Manage Jenkins" → "Plugins"
2. Click "Available plugins"
3. Search and install:
   - Git Plugin
   - GitHub Integration Plugin
   - Docker Pipeline
   - Pipeline
   - Blue Ocean (optional, for better UI)

4. Click "Install" and restart Jenkins when done

### Step 10: Install Docker in Jenkins Container

```powershell
# Install Docker CLI in Jenkins container
docker exec -u root jenkins bash -c "
apt-get update &&
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release &&
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable' > /etc/apt/sources.list.d/docker.list &&
apt-get update &&
apt-get install -y docker-ce-cli
"

# Add Jenkins user to Docker group
docker exec -u root jenkins usermod -aG docker jenkins

# Restart Jenkins
docker restart jenkins
```

Wait 30 seconds after restart.

### Step 11: Clone the Project Repository

Open PowerShell or Command Prompt:

```powershell
# Create a workspace directory
mkdir C:\DevOps-Projects
cd C:\DevOps-Projects

# Clone the repository
git clone https://github.com/hshar/website.git
cd website

# Create develop branch
git checkout -b develop
```

### Step 12: Create Project Files

Create the following files in the project directory:

**Dockerfile:**
```dockerfile
FROM hshar/webapp
WORKDIR /var/www/html
COPY . /var/www/html/
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
```

**test.sh:**
```bash
#!/bin/bash
echo "Starting tests..."

if [ "$(docker ps -q -f name=abode-webapp)" ]; then
    echo "✓ Container is running"
else
    echo "✗ Container is not running"
    exit 1
fi

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80)
if [ $HTTP_CODE -eq 200 ]; then
    echo "✓ Application is accessible"
else
    echo "✗ Application returned HTTP $HTTP_CODE"
    exit 1
fi

echo "All tests passed!"
```

**Jenkinsfile:** (Copy from the main solution document)

### Step 13: Test Docker Build Locally

```powershell
# Build the Docker image
docker build -t hshar/webapp:test .

# Run the container
docker run -d --name test-webapp -p 8081:80 hshar/webapp:test

# Test in browser
start http://localhost:8081

# Stop and remove
docker stop test-webapp
docker rm test-webapp
```

### Step 14: Setup Jenkins Pipeline

1. In Jenkins, click "New Item"
2. Name: "Abode-DevOps-Pipeline"
3. Type: "Pipeline"
4. Under "Pipeline":
   - Definition: "Pipeline script from SCM"
   - SCM: "Git"
   - Repository URL: Path to your local repo or GitHub URL
   - Branch: `*/master` and `*/develop`
   - Script Path: `Jenkinsfile`
5. Click "Save"

### Step 15: Test the Pipeline

```powershell
# Make sure you're in the project directory
cd C:\DevOps-Projects\website

# Make a test change
echo "<h1>Test Update</h1>" >> index.html

# Commit and trigger Jenkins manually first
git add .
git commit -m "Test pipeline"

# In Jenkins, click "Build Now" on your pipeline
```

---

## Verification Checklist

After setup, verify:

- [ ] Docker Desktop is running
- [ ] Jenkins is accessible at http://localhost:8080
- [ ] Jenkins can execute Docker commands
- [ ] Pipeline job is created in Jenkins
- [ ] Project files (Dockerfile, Jenkinsfile, test.sh) exist
- [ ] You can build Docker image locally
- [ ] Test script runs successfully

---

## Common Issues and Solutions

### Issue 1: Docker not starting
**Solution:** 
- Check if virtualization is enabled in BIOS
- Ensure Hyper-V is enabled: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`

### Issue 2: Jenkins can't access Docker
**Solution:**
```powershell
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins
```

### Issue 3: Port 8080 already in use
**Solution:**
```powershell
# Find what's using the port
netstat -ano | findstr :8080

# Kill the process or use a different port for Jenkins
docker run -d -p 9090:8080 -p 50000:50000 --name jenkins jenkins/jenkins:lts
```

### Issue 4: WSL not installing
**Solution:**
- Ensure Windows is updated
- Run: `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
- Run: `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
- Restart computer

### Issue 5: Permission denied when running test.sh
**Solution:**
```bash
# In WSL or Git Bash
chmod +x test.sh
```

---

## Next Steps

1. ✅ Complete this quick start guide
2. 📚 Read the full solution document for detailed explanations
3. 🔧 Configure GitHub webhook for automatic triggers
4. 🧪 Test both master and develop branch workflows
5. 📊 Monitor Jenkins build history
6. 🚀 Deploy to production

---

## Useful Commands Reference

### Docker Commands
```powershell
# List running containers
docker ps

# List all containers
docker ps -a

# View logs
docker logs jenkins
docker logs abode-webapp

# Stop container
docker stop <container-name>

# Remove container
docker rm <container-name>

# Remove image
docker rmi <image-name>

# Clean up everything
docker system prune -a
```

### Jenkins Commands
```powershell
# Restart Jenkins
docker restart jenkins

# View Jenkins logs
docker logs -f jenkins

# Backup Jenkins data
docker cp jenkins:/var/jenkins_home C:\Jenkins-Backup
```

### Git Commands
```powershell
# Check status
git status

# Create branch
git checkout -b branch-name

# Switch branch
git checkout branch-name

# View branches
git branch -a

# Push to remote
git push origin branch-name
```

---

## Support

If you encounter issues:
1. Check Docker Desktop is running
2. Check Jenkins container is running: `docker ps`
3. Check Jenkins logs: `docker logs jenkins`
4. Restart Docker Desktop
5. Restart Jenkins: `docker restart jenkins`

Good luck with your DevOps Capstone Project! 🚀
