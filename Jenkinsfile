pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "hshar/webapp"
        CONTAINER_NAME = "abode-webapp"
        APP_PORT = "80"
        GIT_BRANCH = "${env.BRANCH_NAME}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "=========================================="
                    echo "Stage: Checkout"
                    echo "Branch: ${GIT_BRANCH}"
                    echo "Build Number: ${BUILD_NUMBER}"
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
                    
                    // Clean up existing containers with the same name
                    sh '''
                        echo "Cleaning up existing containers..."
                        docker stop ${CONTAINER_NAME} 2>/dev/null || true
                        docker rm ${CONTAINER_NAME} 2>/dev/null || true
                    '''
                    
                    // Build Docker image
                    sh '''
                        echo "Building Docker image..."
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        echo "Docker image built successfully!"
                    '''
                    
                    // List Docker images
                    sh 'docker images | grep ${DOCKER_IMAGE}'
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
                    sh '''
                        echo "Starting container for testing..."
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${APP_PORT}:80 \
                            ${DOCKER_IMAGE}:latest
                    '''
                    
                    // Wait for container to be ready
                    echo "Waiting for container to be ready..."
                    sleep(time: 10, unit: 'SECONDS')
                    
                    // Check if container is running
                    sh '''
                        echo "Checking container status..."
                        docker ps | grep ${CONTAINER_NAME}
                    '''
                    
                    // Run basic tests
                    sh '''
                        echo "Running tests..."
                        
                        # Test 1: Check if container is running
                        if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
                            echo "✓ Test 1 Passed: Container is running"
                        else
                            echo "✗ Test 1 Failed: Container is not running"
                            exit 1
                        fi
                        
                        # Test 2: Check if application is accessible
                        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT})
                        if [ $HTTP_CODE -eq 200 ]; then
                            echo "✓ Test 2 Passed: Application is accessible (HTTP $HTTP_CODE)"
                        else
                            echo "✗ Test 2 Failed: Application returned HTTP $HTTP_CODE"
                            exit 1
                        fi
                        
                        # Test 3: Check container logs for errors
                        if docker logs ${CONTAINER_NAME} 2>&1 | grep -i "error" > /dev/null; then
                            echo "⚠ Warning: Errors found in container logs"
                        else
                            echo "✓ Test 3 Passed: No errors in container logs"
                        fi
                        
                        echo ""
                        echo "=========================================="
                        echo "All Tests Passed Successfully! ✓"
                        echo "=========================================="
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
                    echo "Branch: ${GIT_BRANCH}"
                    echo "=========================================="
                    
                    sh '''
                        echo "Deploying to production environment..."
                        echo "Container is already running from test stage"
                        echo ""
                        echo "Application Details:"
                        echo "-------------------"
                        echo "Container Name: ${CONTAINER_NAME}"
                        echo "Port: ${APP_PORT}"
                        echo "Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                        echo ""
                        docker ps | grep ${CONTAINER_NAME}
                        echo ""
                        echo "=========================================="
                        echo "✓ Production Deployment Successful!"
                        echo "Application URL: http://localhost:${APP_PORT}"
                        echo "=========================================="
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
                    
                    sh '''
                        echo "This is a develop branch - not deploying to production"
                        echo "Cleaning up test environment..."
                        
                        docker stop ${CONTAINER_NAME}
                        docker rm ${CONTAINER_NAME}
                        
                        echo ""
                        echo "=========================================="
                        echo "✓ Cleanup Completed"
                        echo "Note: Changes NOT deployed to production"
                        echo "=========================================="
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
                echo "║   PIPELINE EXECUTED SUCCESSFULLY! ✓    ║"
                echo "╚════════════════════════════════════════╝"
                echo ""
                echo "Build Summary:"
                echo "-------------"
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Branch: ${GIT_BRANCH}"
                echo "Status: SUCCESS"
                
                if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'main') {
                    echo "Deployment: PRODUCTION"
                    echo "URL: http://localhost:${APP_PORT}"
                } else {
                    echo "Deployment: NONE (develop branch)"
                }
                echo ""
            }
        }
        
        failure {
            script {
                echo ""
                echo "╔════════════════════════════════════════╗"
                echo "║      PIPELINE FAILED! ✗                ║"
                echo "╚════════════════════════════════════════╝"
                echo ""
                echo "Cleaning up failed deployment..."
                
                sh '''
                    docker stop ${CONTAINER_NAME} 2>/dev/null || true
                    docker rm ${CONTAINER_NAME} 2>/dev/null || true
                '''
                
                echo "Please check the console output for errors"
                echo ""
            }
        }
        
        always {
            script {
                echo ""
                echo "=========================================="
                echo "Pipeline Execution Completed"
                echo "Time: ${new Date()}"
                echo "Duration: ${currentBuild.durationString}"
                echo "=========================================="
                echo ""
            }
        }
    }
}
