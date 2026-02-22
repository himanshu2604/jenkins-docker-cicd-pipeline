# Pipeline Configuration Guide

## Overview

The Jenkins pipeline automates the entire CI/CD workflow from code commit to production deployment.

---

## Pipeline Structure

```groovy
pipeline {
    agent any
    environment { ... }
    stages { ... }
    post { ... }
}
```

---

## Environment Variables

```groovy
environment {
    DOCKER_IMAGE = "hshar/webapp"        # Docker image name
    CONTAINER_NAME = "abode-webapp"      # Container name
    APP_PORT = "8081"                    # Application port
}
```

**To modify:**
1. Edit `Jenkinsfile`
2. Change values as needed
3. Commit and push

---

## Pipeline Stages

### Stage 1: Checkout
**Purpose:** Pull code from GitHub  
**Trigger:** Automatic on git push  
**Actions:**
- Clones repository
- Checks out specified branch

```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

### Stage 2: Build
**Purpose:** Create Docker image  
**Actions:**
- Stops/removes existing containers
- Builds new Docker image
- Tags image with build number

```groovy
stage('Build') {
    steps {
        bat 'docker build -t %DOCKER_IMAGE%:latest .'
    }
}
```

### Stage 3: Test
**Purpose:** Validate application  
**Actions:**
- Runs container on port 8081
- Executes automated tests
- Checks application accessibility

```groovy
stage('Test') {
    steps {
        bat 'docker run -d --name %CONTAINER_NAME% -p %APP_PORT%:80 %DOCKER_IMAGE%:latest'
        sleep 10
        bat 'curl -f http://localhost:%APP_PORT%'
    }
}
```

### Stage 4: Deploy (Master Only)
**Purpose:** Deploy to production  
**Condition:** Only runs on `master` branch  
**Actions:**
- Keeps container running
- Application available at http://localhost:8081

```groovy
stage('Deploy') {
    when {
        branch 'master'
    }
    steps {
        echo "Deployed to Production!"
    }
}
```

### Stage 5: Cleanup (Develop Only)
**Purpose:** Remove test containers  
**Condition:** Only runs on `develop` branch  
**Actions:**
- Stops container
- Removes container
- Prevents production deployment

```groovy
stage('Cleanup - Develop') {
    when {
        branch 'develop'
    }
    steps {
        bat 'docker stop %CONTAINER_NAME%'
        bat 'docker rm %CONTAINER_NAME%'
    }
}
```

---

## Branch Strategy

| Branch | Build | Test | Deploy | Cleanup |
|--------|-------|------|--------|---------|
| master | ✅ | ✅ | ✅ | ❌ |
| develop | ✅ | ✅ | ❌ | ✅ |

**Flow Visualization:**
```
Master:  Commit → Build → Test → Deploy → Production (Running)
Develop: Commit → Build → Test → Cleanup → Stop
```

---

## Triggers

### 1. Manual Trigger
- Click "Build Now" in Jenkins
- Runs immediately

### 2. Webhook Trigger
```groovy
// In Jenkins job configuration
Build Triggers:
  ☑ GitHub hook trigger for GITScm polling
```

**GitHub Webhook URL:**
```
http://YOUR_JENKINS_URL:8080/github-webhook/
```

### 3. SCM Polling (Recommended)
```groovy
// Check GitHub every 5 minutes
Poll SCM: H/5 * * * *
```

---

## Post Actions

### On Success
```groovy
post {
    success {
        echo "Pipeline SUCCESS!"
    }
}
```

### On Failure
```groovy
post {
    failure {
        bat 'docker stop %CONTAINER_NAME% 2>nul'
        bat 'docker rm %CONTAINER_NAME% 2>nul'
    }
}
```

---

## Customization

### Change Application Port

**In Jenkinsfile:**
```groovy
environment {
    APP_PORT = "9090"  // Change to desired port
}
```

### Add New Stage

```groovy
stage('Security Scan') {
    steps {
        echo "Running security scan..."
        // Add your commands
    }
}
```

### Add Email Notifications

```groovy
post {
    failure {
        emailext (
            subject: "Build Failed: ${env.JOB_NAME}",
            body: "Build ${env.BUILD_NUMBER} failed.",
            to: "your-email@example.com"
        )
    }
}
```

### Modify Test Commands

```groovy
stage('Test') {
    steps {
        bat 'docker run ...'
        sleep 10
        bat 'curl -f http://localhost:%APP_PORT%'
        bat 'your-custom-test-command'  // Add here
    }
}
```

---

## Pipeline Parameters

### Add Build Parameters

```groovy
pipeline {
    agent any
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Deployment environment'
        )
        string(
            name: 'VERSION',
            defaultValue: 'latest',
            description: 'Docker image version'
        )
    }
    // ... stages
}
```

**Access in pipeline:**
```groovy
echo "Deploying ${params.VERSION} to ${params.ENVIRONMENT}"
```

---

## Advanced Configuration

### Parallel Stages

```groovy
stage('Parallel Tests') {
    parallel {
        stage('Unit Tests') {
            steps { bat 'run-unit-tests' }
        }
        stage('Integration Tests') {
            steps { bat 'run-integration-tests' }
        }
    }
}
```

### Timeout Configuration

```groovy
stage('Build') {
    options {
        timeout(time: 10, unit: 'MINUTES')
    }
    steps {
        bat 'docker build ...'
    }
}
```

### Retry on Failure

```groovy
stage('Test') {
    steps {
        retry(3) {
            bat 'curl -f http://localhost:8081'
        }
    }
}
```

---

## Environment-Specific Configuration

### Development
```groovy
environment {
    APP_PORT = "8081"
    LOG_LEVEL = "DEBUG"
}
```

### Production
```groovy
environment {
    APP_PORT = "80"
    LOG_LEVEL = "INFO"
}
```

---

## Best Practices

1. **Keep stages focused** - One responsibility per stage
2. **Use meaningful names** - Clear stage and variable names
3. **Add error handling** - Use try-catch blocks
4. **Keep secrets secure** - Use Jenkins credentials
5. **Document changes** - Comment complex logic
6. **Test locally first** - Build Docker images locally before pushing

---

## Monitoring

### View Pipeline Status

**Jenkins Dashboard:**
- Build history with status indicators
- Console output for detailed logs
- Blue Ocean view for visual pipeline

**Commands:**
```bash
# Check container status
docker ps | grep abode-webapp

# View application logs
docker logs abode-webapp

# View Jenkins logs
docker logs jenkins
```

---

## Debugging

### Pipeline Fails at Build Stage

```bash
# Check Dockerfile exists
ls Dockerfile

# Verify Docker is running
docker ps

# Build manually to see errors
docker build -t test .
```

### Pipeline Fails at Test Stage

```bash
# Check if container started
docker ps -a | grep abode-webapp

# View container logs
docker logs abode-webapp

# Test manually
docker run -d --name test -p 8081:80 hshar/webapp:latest
curl http://localhost:8081
```

### Pipeline Hangs

```groovy
// Add timeout
stage('Test') {
    options {
        timeout(time: 5, unit: 'MINUTES')
    }
    steps { ... }
}
```

---

## Sample Jenkinsfile Snippets

### Skip Stage Conditionally

```groovy
stage('Deploy') {
    when {
        anyOf {
            branch 'master'
            branch 'release/*'
        }
    }
    steps { ... }
}
```

### Use Docker Credentials

```groovy
stage('Push Image') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'docker-hub',
            usernameVariable: 'USER',
            passwordVariable: 'PASS'
        )]) {
            bat 'docker login -u %USER% -p %PASS%'
            bat 'docker push hshar/webapp:latest'
        }
    }
}
```

### Run Tests in Container

```groovy
stage('Test') {
    agent {
        docker {
            image 'hshar/webapp:latest'
            args '-p 8081:80'
        }
    }
    steps {
        bat 'your-test-command'
    }
}
```

---

## Performance Optimization

1. **Use Docker layer caching**
2. **Parallelize independent stages**
3. **Clean up old images:**
   ```groovy
   bat 'docker image prune -f'
   ```
4. **Use shallow git clone:**
   ```groovy
   checkout([$class: 'GitSCM', extensions: [[$class: 'CloneOption', depth: 1]]])
   ```

---

## Configuration Files

### Jenkinsfile Location
```
/jenkins-docker-cicd-pipeline/Jenkinsfile
```

### Jenkins Job Configuration
```
Jenkins → Your Pipeline → Configure
```

### Environment Variables
- Set in Jenkinsfile `environment` block
- Or in Jenkins: Manage Jenkins → Configure System

---

## Quick Reference

| Action | Command |
|--------|---------|
| Edit pipeline | Modify `Jenkinsfile` and commit |
| Change port | Update `APP_PORT` variable |
| Add stage | Insert new `stage {}` block |
| Skip stage | Add `when` condition |
| View logs | Jenkins console output |
| Retry build | Click "Rebuild" |

---

## Support

- **Jenkinsfile syntax:** https://www.jenkins.io/doc/book/pipeline/syntax/
- **Docker commands:** https://docs.docker.com/engine/reference/commandline/cli/
- **Console output:** Jenkins → Build → Console Output

---

**Configuration Time: ~5 minutes**  
**Complexity: Intermediate**

For implementation details, see `Jenkinsfile` in the repository.
