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
                    
                    // Build Docker image
                    bat '''
                        echo Building Docker image...
                        docker build -t %DOCKER_IMAGE%:%BUILD_NUMBER% .
                        docker tag %DOCKER_IMAGE%:%BUILD_NUMBER% %DOCKER_IMAGE%:latest
                        echo Docker image built successfully!
                    '''
                    
                    // List images
                    bat 'docker images | findstr %DOCKER_IMAGE%'
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
                    bat 'docker ps | findstr %CONTAINER_NAME%'
                    
                    // Run tests using PowerShell (since test.sh won't work directly on Windows)
                    bat '''
                        echo Running tests...
                        
                        REM Test 1: Check if container is running
                        docker ps | findstr %CONTAINER_NAME% && (
                            echo PASS: Container is running
                        ) || (
                            echo FAIL: Container is not running
                            exit /b 1
                        )
                        
                        REM Test 2: Check if application is accessible
                        curl -s -o nul -w "%%{http_code}" http://localhost:%APP_PORT% > http_code.txt
                        set /p HTTP_CODE=<http_code.txt
                        if "%HTTP_CODE%"=="200" (
                            echo PASS: Application is accessible ^(HTTP 200^)
                        ) else (
                            echo FAIL: Application returned HTTP %HTTP_CODE%
                            exit /b 1
                        )
                        del http_code.txt
                        
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
                        docker ps | findstr %CONTAINER_NAME%
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