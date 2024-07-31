pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_PATH = "${env.WORKSPACE}/terraform"  // Adjust this path if Terraform is located elsewhere
        AWS_CREDENTIALS = 'aws-credentials'  // Your AWS credentials ID for Terraform
    }

    options {
        timeout(time: 1, unit: 'HOURS') // Set build timeout to 1 hour
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep only the last 10 builds
    }

    stages {
        stage('Terraform Init') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${AWS_CREDENTIALS}", passwordVariable: 'AWS_SECRET_KEY', usernameVariable: 'AWS_ACCESS_KEY')]) {
                        env.AWS_ACCESS_KEY_ID = "${AWS_ACCESS_KEY}"
                        env.AWS_SECRET_ACCESS_KEY = "${AWS_SECRET_KEY}"
                        sh """
                        cd ${env.TERRAFORM_PATH}
                        terraform init
                        """
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${AWS_CREDENTIALS}", passwordVariable: 'AWS_SECRET_KEY', usernameVariable: 'AWS_ACCESS_KEY')]) {
                        env.AWS_ACCESS_KEY_ID = "${AWS_ACCESS_KEY}"
                        env.AWS_SECRET_ACCESS_KEY = "${AWS_SECRET_KEY}"
                        sh """
                        cd ${env.TERRAFORM_PATH}
                        terraform apply -auto-approve
                        """
                    }
                }
            }
        }
        stage('Configure Kubeconfig') {
            steps {
                script {
                    def kubeconfig = sh(script: "cd ${env.TERRAFORM_PATH} && terraform output -raw kubeconfig", returnStdout: true).trim()
                    writeFile file: "${KUBECONFIG_PATH}", text: kubeconfig
                    env.KUBECONFIG = "${env.WORKSPACE}/${KUBECONFIG_PATH}"
                    echo "KUBECONFIG is set to ${env.KUBECONFIG}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_REPO}:${env.BUILD_NUMBER}"
                    docker.build("${DOCKER_REPO}:${env.BUILD_NUMBER}")
                }
            }
        }
        stage('Test Docker Image') {
            steps {
                script {
                    echo 'Running tests...'
                    // Implement your test logic here
                    echo 'Tests passed!'
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image ${DOCKER_REPO}:${env.BUILD_NUMBER}"
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS}") {
                        docker.image("${DOCKER_REPO}:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-credentials-id', kubeconfig: "${env.KUBECONFIG}"]) {
                        echo "Deploying Docker image to Kubernetes"
                        sh """
                        kubectl apply -f ${env.WORKSPACE}/k8s/deployment.yaml
                        kubectl apply -f ${env.WORKSPACE}/k8s/service.yaml
                        """
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
                to: 'your-email@example.com'
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
                to: 'your-email@example.com'
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
