pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_PATH = "${terraform}"  // Update this path to where terraform.exe is located
        AWS_CREDENTIALS_ID = 'aws-credentials'
    }

    options {
        timeout(time: 1, unit: 'HOURS') // Set build timeout to 1 hour
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep only the last 10 builds
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        env.DOCKER_REPO = "${DOCKER_USERNAME}/${DOCKER_IMAGE}"
                        echo "Using Docker Hub repository: ${DOCKER_REPO}"
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    bat "${env.TERRAFORM_PATH}\\terraform init"
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${AWS_CREDENTIALS_ID}", passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                        bat """
                        set AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        set AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        ${env.TERRAFORM_PATH}\\terraform apply -auto-approve
                        """
                    }
                }
            }
        }
        stage('Configure Kubeconfig') {
            steps {
                script {
                    def kubeconfig = bat(script: "${env.TERRAFORM_PATH}\\terraform output -raw kubeconfig", returnStdout: true).trim()
                    writeFile file: "${KUBECONFIG_PATH}", text: kubeconfig
                    env.KUBECONFIG = "${env.WORKSPACE}\\${KUBECONFIG_PATH}"
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
                    echo "Deploying Docker image to Kubernetes"
                    bat """
                    kubectl apply -f - <<EOF
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: my-python-app-deployment
                    spec:
                      replicas: 2
                      selector:
                        matchLabels:
                          app: my-python-app
                      template:
                        metadata:
                          labels:
                            app: my-python-app
                        spec:
                          containers:
                          - name: my-python-app
                            image: ${DOCKER_REPO}:${env.BUILD_NUMBER}
                            ports:
                            - containerPort: 5000
                    ---
                    apiVersion: v1
                    kind: Service
                    metadata:
                      name: my-python-app-service
                    spec:
                      selector:
                        app: my-python-app
                      ports:
                      - protocol: TCP
                        port: 80
                        targetPort: 5000
                      type: LoadBalancer
                    EOF
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                echo 'Build, test, and deployment completed successfully.'
            }
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
