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
                    
                    // Clean up existing containers
                    bat '''
                        echo Cleaning up existing containers...
                        docker stop %CONTAINER_NAME% 2>nul || echo Container not running
                        docker rm %CONTAINER_NAME% 2>nul || echo Container not found
                    '''
                    
                    // Build Docker image - THIS WAS MISSING!
                    bat '''
                        echo Building Docker image...
                        docker build -t %DOCKER_IMAGE%:%BUILD_NUMBER% .
                        docker tag %DOCKER_IMAGE%:%BUILD_NUMBER% %DOCKER_IMAGE%:latest
                        echo Docker image built successfully!
                    '''
                    
                    // List images
                    bat 'docker images'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Test - Running Application Tests"
                    echo "=========================================="
                    
                    // Run container for testing
                    bat '''
                        echo Starting container for testing...
                        docker run -d --name %CONTAINER_NAME% -p %APP_PORT%:80 %DOCKER_IMAGE%:latest
                    '''
                    
                    // Wait for container to be ready
                    echo "Waiting for container to be ready..."
                    sleep(time: 10, unit: 'SECONDS')
                    
                    // Check container status
                    bat 'docker ps'
                    
                    // Run tests
                    bat '''
                        echo Running tests...
                        
                        echo Test 1: Checking if container is running
                        docker ps | findstr %CONTAINER_NAME% && echo PASS: Container is running || (echo FAIL: Container not running & exit /b 1)
                        
                        echo Test 2: Checking application accessibility
                        curl -f http://localhost:%APP_PORT% && echo PASS: Application accessible || (echo FAIL: Application not accessible & exit /b 1)
                        
                        echo.
                        echo ==========================================
                        echo All Tests Passed Successfully!
                        echo ==========================================
                    '''
                }
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
                    
                    bat '''
                        echo Deploying to production...
                        echo Container is running from test stage
                        echo.
                        echo Application Details:
                        echo -------------------
                        echo Container Name: %CONTAINER_NAME%
                        echo Port: %APP_PORT%
                        echo Image: %DOCKER_IMAGE%:%BUILD_NUMBER%
                        echo.
                        docker ps
                        echo.
                        echo ==========================================
                        echo Production Deployment Successful!
                        echo Application URL: http://localhost:%APP_PORT%
                        echo ==========================================
                    '''
                }
            }
        }
        
        stage('Cleanup - Develop Branch') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Cleanup - Develop Branch"
                    echo "=========================================="
                    
                    bat '''
                        echo This is develop branch - not deploying to production
                        echo Cleaning up test environment...
                        
                        docker stop %CONTAINER_NAME%
                        docker rm %CONTAINER_NAME%
                        
                        echo.
                        echo ==========================================
                        echo Cleanup Completed
                        echo Note: Changes NOT deployed to production
                        echo ==========================================
                    '''
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo ""
                echo "╔════════════════════════════════════════╗"
                echo "║   PIPELINE EXECUTED SUCCESSFULLY!      ║"
                echo "╚════════════════════════════════════════╝"
            }
        }
        failure {
            script {
                echo ""
                echo "╔════════════════════════════════════════╗"
                echo "║         PIPELINE FAILED!               ║"
                echo "╚════════════════════════════════════════╝"
                
                bat '''
                    docker stop %CONTAINER_NAME% 2>nul || echo Container already stopped
                    docker rm %CONTAINER_NAME% 2>nul || echo Container already removed
                '''
            }
        }
    }
}