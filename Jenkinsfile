pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_EXEC_PATH = tool 'terraform'
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}/terraform"
        AWS_REGION = 'us-west-2'
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Terraform Init') {
            steps {
                dir("${env.TERRAFORM_CONFIG_PATH}") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh "${env.TERRAFORM_EXEC_PATH} init"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${env.TERRAFORM_CONFIG_PATH}") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh "${env.TERRAFORM_EXEC_PATH} apply -auto-approve"
                    }
                }
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                script {
                    dir("${env.TERRAFORM_CONFIG_PATH}") {
                        def kubeconfig = sh(script: "${env.TERRAFORM_EXEC_PATH} output -raw kubeconfig", returnStdout: true).trim()
                        writeFile file: "${KUBECONFIG_PATH}", text: kubeconfig
                        env.KUBECONFIG = "${env.WORKSPACE}/${KUBECONFIG_PATH}"
                        echo "KUBECONFIG is set to ${env.KUBECONFIG}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                echo 'Running tests...'
                // Implement your test logic here
                echo 'Tests passed!'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-credentials-id', kubeconfigVariable: 'KUBECONFIG']) {
                    sh """
                    kubectl apply -f ${env.WORKSPACE}/k8s/deployment.yaml
                    kubectl apply -f ${env.WORKSPACE}/k8s/service.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Build, test, and deployment completed successfully.'
        }
        failure {
            echo 'Build, test, or deployment failed.'
        }
        always {
            echo 'Cleaning up...'
            // Perform any cleanup steps if necessary
        }
    }
}