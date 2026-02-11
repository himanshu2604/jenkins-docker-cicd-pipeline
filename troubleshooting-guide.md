# Troubleshooting Guide - DevOps Capstone Project

## Common Issues and Solutions

### Issue 1: Jenkins Can't Connect to Docker

**Symptoms:**
- Jenkins pipeline fails with "docker: command not found"
- Permission denied errors when running Docker commands

**Solutions:**

**Solution A: Add Jenkins user to Docker group**
```bash
# If Jenkins is running in Docker
docker exec -u root jenkins usermod -aG docker jenkins
docker restart jenkins

# If Jenkins is installed natively on Windows WSL
sudo usermod -aG docker $USER
newgrp docker
```

**Solution B: Install Docker CLI in Jenkins container**
```bash
docker exec -u root jenkins bash -c "
apt-get update &&
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release &&
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable' > /etc/apt/sources.list.d/docker.list &&
apt-get update &&
apt-get install -y docker-ce-cli
"
```

---

### Issue 2: Port Already in Use

**Symptoms:**
- Error: "Bind for 0.0.0.0:80 failed: port is already allocated"
- Jenkins or application won't start

**Solution A: Find and stop conflicting process (Windows)**
```powershell
# Find process using port 80
netstat -ano | findstr :80

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

**Solution B: Use a different port**
```bash
# Modify docker run command
docker run -d --name abode-webapp -p 8081:80 hshar/webapp:latest

# Or modify docker-compose.yml
ports:
  - "8081:80"  # Change from 80:80
```

---

### Issue 3: Docker Desktop Not Starting (Windows)

**Symptoms:**
- Docker Desktop stuck on "Starting..."
- WSL 2 backend errors

**Solutions:**

**Solution A: Restart WSL**
```powershell
# Run in PowerShell as Administrator
wsl --shutdown
# Wait 10 seconds
# Start Docker Desktop again
```

**Solution B: Enable Virtualization in BIOS**
1. Restart computer
2. Enter BIOS (usually F2, F12, or DEL key during startup)
3. Find Virtualization Technology (Intel VT-x or AMD-V)
4. Enable it
5. Save and exit

**Solution C: Enable Hyper-V**
```powershell
# Run in PowerShell as Administrator
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
# Restart computer
```

**Solution D: Reinstall Docker Desktop**
1. Uninstall Docker Desktop completely
2. Delete: `C:\Program Files\Docker`
3. Delete: `%LOCALAPPDATA%\Docker`
4. Restart computer
5. Reinstall Docker Desktop

---

### Issue 4: Jenkins Initial Password Not Found

**Symptoms:**
- Can't access Jenkins web interface
- Initial admin password file not found

**Solutions:**

**If Jenkins is in Docker:**
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**If Jenkins is installed natively:**
```bash
# Windows
type "C:\Program Files\Jenkins\secrets\initialAdminPassword"

# Linux
cat /var/lib/jenkins/secrets/initialAdminPassword
```

**If file doesn't exist:**
```bash
# Reset Jenkins
docker stop jenkins
docker rm jenkins
docker volume rm jenkins_home
# Then reinstall Jenkins
```

---

### Issue 5: Pipeline Fails on Test Stage

**Symptoms:**
- Build stage succeeds but test stage fails
- Container not accessible

**Solutions:**

**Solution A: Increase wait time**
```groovy
// In Jenkinsfile
sleep(time: 15, unit: 'SECONDS')  // Increase from 5 to 15
```

**Solution B: Check container logs**
```bash
docker logs abode-webapp
```

**Solution C: Verify port mapping**
```bash
docker ps
# Check if port 80 is correctly mapped
```

**Solution D: Test manually**
```bash
# Run container manually
docker run -d --name test-webapp -p 80:80 hshar/webapp:latest

# Test access
curl http://localhost:80

# Check logs
docker logs test-webapp
```

---

### Issue 6: GitHub Webhook Not Triggering Jenkins

**Symptoms:**
- Manual builds work but automatic builds don't trigger
- No builds on git push

**Solutions:**

**Solution A: For localhost development - Use ngrok**
```bash
# Install ngrok
choco install ngrok -y

# Expose Jenkins
ngrok http 8080

# Use the ngrok URL in GitHub webhook
# Example: https://abc123.ngrok.io/github-webhook/
```

**Solution B: Check webhook configuration**
1. GitHub → Repository → Settings → Webhooks
2. Verify URL format: `http://JENKINS_URL/github-webhook/`
3. Check Recent Deliveries for errors
4. Ensure SSL verification is OFF for testing

**Solution C: Configure Jenkins correctly**
1. Jenkins → Manage Jenkins → Configure System
2. GitHub section → Add GitHub Server
3. In Pipeline job → Configure:
   - ✓ GitHub hook trigger for GITScm polling

---

### Issue 7: Permission Denied Errors in Container

**Symptoms:**
- "Permission denied" when accessing /var/www/html
- Files not copying to container

**Solutions:**

**Solution A: Fix Dockerfile permissions**
```dockerfile
# Add to Dockerfile
RUN chmod -R 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html
```

**Solution B: Run container with correct user**
```bash
docker run -d --name abode-webapp -p 80:80 --user www-data hshar/webapp:latest
```

---

### Issue 8: test.sh Script Not Executing

**Symptoms:**
- Error: "Permission denied: ./test.sh"
- Script won't run in Jenkins

**Solutions:**

**Solution A: Make script executable**
```bash
chmod +x test.sh
git add test.sh
git commit -m "Make test.sh executable"
git push
```

**Solution B: Run with bash explicitly**
```groovy
// In Jenkinsfile
sh 'bash test.sh'
// instead of
sh './test.sh'
```

---

### Issue 9: Ansible Playbook Fails

**Symptoms:**
- "ansible-playbook: command not found"
- Module errors

**Solutions:**

**Solution A: Install Ansible in WSL**
```bash
# Open Ubuntu WSL
sudo apt update
sudo apt install ansible -y
ansible --version
```

**Solution B: Fix module dependencies**
```bash
# Install required Python modules
pip3 install docker
pip3 install docker-compose
```

**Solution C: Run with correct privileges**
```bash
ansible-playbook ansible-playbook.yml --ask-become-pass
```

---

### Issue 10: Docker Build Fails

**Symptoms:**
- "Error response from daemon: no such file or directory"
- Build context errors

**Solutions:**

**Solution A: Ensure Dockerfile is in project root**
```bash
# Check file structure
ls -la
# Dockerfile should be in the same directory
```

**Solution B: Clear Docker cache**
```bash
docker builder prune -a
docker system prune -a
```

**Solution C: Build with no cache**
```bash
docker build --no-cache -t hshar/webapp:latest .
```

---

### Issue 11: Container Exits Immediately

**Symptoms:**
- Container starts but stops immediately
- Status shows "Exited (0)"

**Solutions:**

**Solution A: Check logs**
```bash
docker logs abode-webapp
```

**Solution B: Run in interactive mode for debugging**
```bash
docker run -it --name test-debug hshar/webapp:latest /bin/bash
```

**Solution C: Verify CMD in Dockerfile**
```dockerfile
# Ensure CMD is correct
CMD ["apachectl", "-D", "FOREGROUND"]
```

---

### Issue 12: Out of Disk Space

**Symptoms:**
- "no space left on device"
- Build fails with storage errors

**Solutions:**

**Solution A: Clean up Docker**
```bash
# Remove unused containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Remove everything
docker system prune -a --volumes -f
```

**Solution B: Check disk space**
```bash
# Windows
wsl df -h

# Clean WSL disk
wsl --shutdown
# In PowerShell:
Optimize-VHD -Path "C:\Users\<YourUsername>\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_*\LocalState\ext4.vhdx" -Mode Full
```

---

## Debug Commands Reference

### Docker Debugging
```bash
# View all containers (including stopped)
docker ps -a

# Inspect container
docker inspect abode-webapp

# View real-time logs
docker logs -f abode-webapp

# Execute command in running container
docker exec -it abode-webapp /bin/bash

# Check container stats
docker stats abode-webapp

# View port mappings
docker port abode-webapp
```

### Jenkins Debugging
```bash
# View Jenkins logs
docker logs -f jenkins

# Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:password help

# Restart Jenkins safely
docker restart jenkins
```

### Network Debugging
```bash
# Test connection
curl -v http://localhost:80

# Check listening ports
netstat -tulpn | grep LISTEN

# Test from inside container
docker exec abode-webapp curl http://localhost:80
```

---

## Getting Help

If you're still stuck:

1. **Check logs systematically:**
   - Docker logs: `docker logs <container-name>`
   - Jenkins logs: Check console output in Jenkins UI
   - System logs: Windows Event Viewer

2. **Verify basic connectivity:**
   - Can you ping localhost?
   - Is Docker running?
   - Is Jenkins accessible?

3. **Try minimal reproduction:**
   - Test each component individually
   - Start with simplest possible configuration
   - Add complexity gradually

4. **Search for specific error messages:**
   - Copy exact error message
   - Search on Stack Overflow, GitHub Issues
   - Check Anthropic documentation

5. **Provide detailed information when asking for help:**
   - Exact error message
   - What you were doing
   - What you've already tried
   - Version information (Docker, Jenkins, Windows)
   - Relevant log output

---

## Prevention Tips

1. **Always check Docker status before starting work**
2. **Commit Dockerfile and Jenkinsfile to version control**
3. **Use `.dockerignore` to exclude unnecessary files**
4. **Regularly clean up Docker resources**
5. **Keep Jenkins and plugins updated**
6. **Document any custom configurations**
7. **Test pipeline locally before pushing**
8. **Use descriptive commit messages**
9. **Monitor resource usage (CPU, RAM, Disk)**
10. **Backup Jenkins configuration regularly**

Good luck with your DevOps project! 🚀
