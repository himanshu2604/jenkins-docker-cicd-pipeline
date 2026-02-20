pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "hshar/webapp"
        CONTAINER_NAME = "abode-webapp"
        APP_PORT = "80"
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Checkout"
                    echo "Branch: ${env.BRANCH_NAME}"
                    echo "=========================================="
                }
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Build - Building Docker Image"
                    echo "=========================================="
                }
                
                bat '''
                    echo Cleaning up existing containers...
                    docker stop %CONTAINER_NAME% 2>nul || echo Container not running
                    docker rm %CONTAINER_NAME% 2>nul || echo Container not found
                '''
                
                bat '''
                    echo .
                    echo Building Docker image...
                    docker build -t %DOCKER_IMAGE%:%BUILD_NUMBER% .
                    if errorlevel 1 exit /b 1
                    docker tag %DOCKER_IMAGE%:%BUILD_NUMBER% %DOCKER_IMAGE%:latest
                    echo Docker image built successfully!
                '''
                
                bat 'docker images'
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Test - Running Tests"
                    echo "=========================================="
                }
                
                bat '''
                    echo Starting container for testing...
                    docker run -d --name %CONTAINER_NAME% -p %APP_PORT%:80 %DOCKER_IMAGE%:latest
                '''
                
                sleep(time: 10, unit: 'SECONDS')
                
                bat 'docker ps'
                
                bat '''
                    echo Running tests...
                    curl -f http://localhost:%APP_PORT%
                    if errorlevel 1 (
                        echo FAIL: Application not accessible
                        exit /b 1
                    )
                    echo PASS: All tests passed!
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                anyOf {
                    branch 'master'
                    branch 'main'
                }
            }
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Deploy to Production"
                    echo "=========================================="
                }
                
                bat '''
                    echo Production deployment complete!
                    echo Application URL: http://localhost:%APP_PORT%
                    docker ps
                '''
            }
        }
        
        stage('Cleanup - Develop Branch') {
            when {
                branch 'develop'
            }
            steps {
                bat '''
                    echo Cleaning up develop branch...
                    docker stop %CONTAINER_NAME%
                    docker rm %CONTAINER_NAME%
                    echo Cleanup completed - NOT deployed to production
                '''
            }
        }
    }
    
    post {
        success {
            echo "Pipeline SUCCESS!"
        }
        failure {
            echo "Pipeline FAILED!"
            bat 'docker stop %CONTAINER_NAME% 2>nul || echo Already stopped'
            bat 'docker rm %CONTAINER_NAME% 2>nul || echo Already removed'
        }
    }
}