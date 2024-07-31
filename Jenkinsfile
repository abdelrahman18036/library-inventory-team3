pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'orange18036/team3-library'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_EXEC_PATH = 'D:\\Programs\\teraform\\terraform.exe'
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}/terraform"
        AWS_CLI_PATH = '"C:\\Program Files\\Amazon\\AWSCLIV2\\aws.exe"'
        KUBECTL_PATH = '"C:\\Program Files\\Docker\\Docker\\resources\\bin\\kubectl.exe"'
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Setup AWS CLI') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aws-orange-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        bat """
                        ${env.AWS_CLI_PATH} configure set aws_access_key_id %AWS_ACCESS_KEY_ID% --profile orange
                        ${env.AWS_CLI_PATH} configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY% --profile orange
                        ${env.AWS_CLI_PATH} configure set region us-west-2 --profile orange
                        """
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    bat """
                    cd ${env.TERRAFORM_CONFIG_PATH}
                    set AWS_PROFILE=orange
                    ${env.TERRAFORM_EXEC_PATH} init
                    """
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    bat """
                    cd ${env.TERRAFORM_CONFIG_PATH}
                    set AWS_PROFILE=orange
                    ${env.TERRAFORM_EXEC_PATH} apply -auto-approve
                    """
                }
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                script {
                    def kubeconfig = bat(script: "cd ${env.TERRAFORM_CONFIG_PATH} && ${env.TERRAFORM_EXEC_PATH} output -raw kubeconfig", returnStdout: true).trim()
                    if (kubeconfig) {
                        writeFile file: "${KUBECONFIG_PATH}", text: kubeconfig
                        env.KUBECONFIG = "${env.WORKSPACE}/${KUBECONFIG_PATH}"
                        echo "KUBECONFIG is set to ${env.KUBECONFIG}"
                    } else {
                        error("Kubeconfig output is missing. Cannot proceed with Kubernetes deployment.")
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    bat "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
                }
            }
        }
         stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    // withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    //     bat """
                    //     docker login -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%
                    //     docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    //     docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                    //     docker push ${DOCKER_IMAGE}:latest
                    //     """
                    // }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-credentials-id', kubeconfig: "${env.KUBECONFIG}"]) {
                        echo "Deploying Docker image to Kubernetes"
                        bat """
                        ${env.KUBECTL_PATH} apply -f ${env.WORKSPACE}/k8s/persistent-volume.yaml
                        ${env.KUBECTL_PATH} apply -f ${env.WORKSPACE}/k8s/persistent-volume-claim.yaml
                        ${env.KUBECTL_PATH} apply -f ${env.WORKSPACE}/k8s/deployment.yaml
                        ${env.KUBECTL_PATH} apply -f ${env.WORKSPACE}/k8s/service.yaml
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
            }
        }
    }
}
