pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
    }

    options {
        // Set build timeout to 1 hour
        timeout(time: 1, unit: 'HOURS')
        // Keep only the last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE}"
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    // Add commands to run your tests here
                    // Example: pip install -r requirements.txt and pytest
                    sh 'pip install -r requirements.txt'
                    sh 'pytest'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying Docker image ${DOCKER_IMAGE}"
                    docker.withRegistry('', "${DOCKER_CREDENTIALS}") {
                        docker.image("${DOCKER_IMAGE}").run('-p 5000:5000')
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                echo 'Build, test, and deployment completed successfully.'
            }
            // Add notification for successful build
            // Example: Send email notification
            emailext(
                subject: "SUCCESS: Jenkins Build ${env.BUILD_NUMBER}",
                body: "The build ${env.BUILD_NUMBER} succeeded.",
                to: 'abdelrahman.18036@gmail.com'
            )
        }
        failure {
            script {
                echo 'Build, test, or deployment failed.'
            }
            // Add notification for failed build
            // Example: Send email notification
            emailext(
                subject: "FAILURE: Jenkins Build ${env.BUILD_NUMBER}",
                body: "The build ${env.BUILD_NUMBER} failed.",
                to: 'abdelrahman.18036@gmail.com'
            )
        }
        always {
            script {
                echo 'Cleaning up...'
                // Perform any cleanup steps if necessary
            }
        }
    }
}
