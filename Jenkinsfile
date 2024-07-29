pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_REPO = 'your-dockerhub-username/my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
    }

    options {
        timeout(time: 1, unit: 'HOURS') // Set build timeout to 1 hour
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep only the last 10 builds
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE}"
                    docker.build("${DOCKER_REPO}:${env.BUILD_NUMBER}")
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo 'Running tests...'
                    echo 'No tests to run.'
                    // Add your test commands here
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying Docker image ${DOCKER_IMAGE}"
                    docker.withRegistry('', "${DOCKER_CREDENTIALS}") {
                        docker.image("${DOCKER_REPO}:${env.BUILD_NUMBER}").push()
                    }
                    docker.withRegistry('', "${DOCKER_CREDENTIALS}") {
                        docker.image("${DOCKER_REPO}:${env.BUILD_NUMBER}").run('-p 5000:5000')
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
