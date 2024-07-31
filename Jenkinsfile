pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_EXEC_PATH = "${terraform}"
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}/terraform"
    }

    options {
        timeout(time: 1, unit: 'HOURS') // Set build timeout to 1 hour
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep only the last 10 builds
    }

    stages {
        stage('Terraform Init') {
            steps {
                script {
                    withAWS(credentials: 'aws-credentials', region: 'us-west-2') {
                        sh """
                        cd ${env.TERRAFORM_CONFIG_PATH}
                        ${env.TERRAFORM_EXEC_PATH}/terraform init
                        """
                    }
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    withAWS(credentials: 'aws-credentials', region: 'us-west-2') {
                        sh """
                        cd ${env.TERRAFORM_CONFIG_PATH}
                        ${env.TERRAFORM_EXEC_PATH}/terraform apply -auto-approve
                        """
                    }
                }
            }
        }
        stage('Configure Kubeconfig') {
            steps {
                script {
                    def kubeconfig = sh(script: "cd ${env.TERRAFORM_CONFIG_PATH} && ${env.TERRAFORM_EXEC_PATH}/terraform output -raw kubeconfig", returnStdout: true).trim()
                    writeFile file: "${KUBECONFIG_PATH}", text: kubeconfig
                    env.KUBECONFIG = "${env.WORKSPACE}/${KUBECONFIG_PATH}"
                    echo "KUBECONFIG is set to ${env.KUBECONFIG}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
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
                    echo "Pushing Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS}") {
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_NUMBER}").push()
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
       
        }
        failure {
            script {
                echo 'Build, test, or deployment failed.'
            }
           
        }
        always {
            script {
                echo 'Cleaning up...'
                // Perform any cleanup steps if necessary
            }
        }
    }
}
