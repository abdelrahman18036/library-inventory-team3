pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-python-app'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_EXEC_PATH = 'D:\\Programs\\teraform\\terraform.exe'
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}/terraform"
        AWS_CLI_PATH = 'D:\\Programs\\aws ac'
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Setup AWS Credentials') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aws-orange-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // Ensure the AWS environment variables are set
                        env.AWS_ACCESS_KEY_ID = "${AWS_ACCESS_KEY_ID}"
                        env.AWS_SECRET_ACCESS_KEY = "${AWS_SECRET_ACCESS_KEY}"
                        echo 'AWS credentials set in environment'
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    bat """
                    cd ${env.TERRAFORM_CONFIG_PATH}
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
                    ${env.TERRAFORM_EXEC_PATH} apply -auto-approve
                    """
                }
            }
        }
        // Other stages...
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
