pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'hshar/webapp'
        CONTAINER_NAME = 'abode-webapp'
        APP_PORT = '8081'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '=========================================='
                echo 'Building Docker Image'
                echo '=========================================='

                bat '''
                    echo Cleaning up...
                    docker stop %CONTAINER_NAME% 2>nul || echo Not running
                    docker rm %CONTAINER_NAME% 2>nul || echo Not found
                '''

                bat '''
                    echo Building Docker image...
                    docker build -t %DOCKER_IMAGE%:latest .
                    echo Build complete!
                '''

                bat 'echo Listing images: && docker images'
            }
        }

        stage('Test') {
            steps {
                echo '=========================================='
                echo 'Running Tests'
                echo '=========================================='

                bat 'docker run -d --name %CONTAINER_NAME% -p %APP_PORT%:80 %DOCKER_IMAGE%:latest'

                sleep 10

                bat 'docker ps'

                bat 'curl -f http://localhost:%APP_PORT%'

                echo 'Tests passed!'
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'master'
                    branch 'main'
                }
            }
            steps {
                echo '=========================================='
                echo 'Deployed to Production!'
                echo 'URL: http://localhost:8081'
                echo '=========================================='
                bat 'docker ps'
            }
        }

        stage('Cleanup - Develop') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Cleaning up develop branch...'
                bat 'docker stop %CONTAINER_NAME%'
                bat 'docker rm %CONTAINER_NAME%'
                echo 'NOT deployed to production'
            }
        }
    }

    post {
        success {
            echo '=========================================='
            echo 'Pipeline SUCCESS!'
            echo '=========================================='
        }
        failure {
            echo 'Pipeline FAILED!'
            bat 'docker stop %CONTAINER_NAME% 2>nul || echo Already stopped'
            bat 'docker rm %CONTAINER_NAME% 2>nul || echo Already removed'
        }
    }
}
