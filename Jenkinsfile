pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'orange18036/team3-library'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_EXEC_PATH = "${terraform}"
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}\\terraform"
        AWS_CLI_PATH = "${aws}"
        KUBECTL_PATH = "${kubectl}"
        NAMESPACE = 'team3'
        TRIVY_PATH = 'D:\\Programs\\trivy'
        HELM_PATH = 'D:\\Programs\\windows-amd64\\helm.exe'
        GRAFANA_ADMIN_PASSWORD = 'admin'
        PROMETHEUS_SCRAPE_INTERVAL = '30s'
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('CI: Build and Test') {
            stages {
                stage('Setup AWS CLI') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'aws-orange-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            bat """
                            "${env.AWS_CLI_PATH}" configure set aws_access_key_id %AWS_ACCESS_KEY_ID% --profile orange
                            "${env.AWS_CLI_PATH}" configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY% --profile orange
                            "${env.AWS_CLI_PATH}" configure set region us-west-2 --profile orange
                            """
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

                stage('Scan Docker Image with Trivy') {
                    steps {
                        script {
                            echo "Scanning Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER} with Trivy"
                            bat """
                                "${env.TRIVY_PATH}" image --format table --output trivy-results.txt ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                                type trivy-results.txt
                            """
                            
                            // Optional: Fail the build if Trivy finds HIGH or CRITICAL vulnerabilities
                            // Uncomment the following lines if you want to enforce this
                            /*
                            def trivyStatus = bat(script: """
                                "${env.TRIVY_PATH}" image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                            """, returnStatus: true)
                            if (trivyStatus != 0) {
                                error "Trivy found vulnerabilities with HIGH or CRITICAL severity"
                            }
                            */
                        }
                    }
                    post {
                        always {
                            archiveArtifacts 'trivy-results.txt'
                        }
                    }
                }

                // Add any additional CI stages here (e.g., unit tests, code quality checks)
            }
        }

        stage('CD: Deploy') {
            stages {
                stage('Terraform Init and Apply') {
                    steps {
                        dir("${env.TERRAFORM_CONFIG_PATH}") {
                            bat """
                            set AWS_PROFILE=orange
                            "${env.TERRAFORM_EXEC_PATH}" init
                            "${env.TERRAFORM_EXEC_PATH}" apply -auto-approve
                            """
                        }
                    }
                }

                stage('Extract EKS Cluster Name') {
                    steps {
                        script {
                            dir("${env.TERRAFORM_CONFIG_PATH}") {
                                env.EKS_CLUSTER_NAME = bat(script: """
                                    @echo off
                                    "${env.TERRAFORM_EXEC_PATH}" output -raw eks_cluster_name
                                """, returnStdout: true).trim()
                                echo "EKS Cluster Name is set to ${env.EKS_CLUSTER_NAME}"
                            }
                        }
                    }
                }

                stage('Configure Kubeconfig') {
                    steps {
                        script {
                            echo "Configuring kubeconfig for EKS Cluster: ${env.EKS_CLUSTER_NAME}"
                            bat """
                                "${env.AWS_CLI_PATH}" eks update-kubeconfig --region us-west-2 --name "${env.EKS_CLUSTER_NAME}" --kubeconfig "${env.WORKSPACE}\\${KUBECONFIG_PATH}" --profile orange
                            """
                            env.KUBECONFIG = "${env.WORKSPACE}\\${KUBECONFIG_PATH}"
                            echo "KUBECONFIG is set to ${env.KUBECONFIG}"
                        }
                    }
                }

                stage('Push Docker Image') {
                    steps {
                        script {
                            echo "Pushing Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                            // withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                            //     bat """
                            //     echo Logging into Docker Hub...
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
                            echo "Deploying to Kubernetes namespace: ${NAMESPACE}"
                            bat """
                                "${env.KUBECTL_PATH}" create namespace ${NAMESPACE} --dry-run=client -o yaml | "${env.KUBECTL_PATH}" apply -f -
                                "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\persistent-volume.yaml -n ${NAMESPACE}
                                "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\persistent-volume-claim.yaml -n ${NAMESPACE}
                                "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\deployment.yaml -n ${NAMESPACE}
                                "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\service.yaml -n ${NAMESPACE}
                            """
                        }
                    }
                }
                 stage('Deploy with Helm') {
                    steps {
                        script {
                            echo "Deploying Helm charts to Kubernetes namespace: ${NAMESPACE}"
                            bat """
                                "${env.HELM_PATH}" repo add prometheus-community https://prometheus-community.github.io/helm-charts
                                "${env.HELM_PATH}" repo add grafana https://grafana.github.io/helm-charts
                                "${env.HELM_PATH}" repo update
                                
                                "${env.HELM_PATH}" install prometheus prometheus-community/prometheus --namespace ${NAMESPACE} --set alertmanager.persistentVolume.enabled=false --set server.persistentVolume.enabled=false --set pushgateway.persistentVolume.enabled=false --set server.global.scrape_interval=${PROMETHEUS_SCRAPE_INTERVAL}
                                
                                "${env.HELM_PATH}" install grafana grafana/grafana --namespace ${NAMESPACE} --set admin.password=${GRAFANA_ADMIN_PASSWORD} --set service.type=LoadBalancer
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }
        failure {
            echo 'CI/CD pipeline failed.'
        }
        always {
            echo 'Cleaning up...'
        }
    }
}