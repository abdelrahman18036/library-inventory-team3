pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'orange18036/team3-library'
        DOCKER_IMAGE_GHCR = 'ghcr.io/orange18036/team3-library'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        KUBECONFIG_PATH = 'kubeconfig'
        TERRAFORM_EXEC_PATH = "${terraform}"
        TERRAFORM_CONFIG_PATH = "${env.WORKSPACE}\\terraform"
        AWS_CLI_PATH = "${aws}"
        KUBECTL_PATH = "${kubectl}"
        NAMESPACE = 'team3'
        TRIVY_PATH = "${trivy}"
        HELM_PATH = "${helm}"
        GRAFANA_ADMIN_PASSWORD = 'admin'
        PROMETHEUS_SCRAPE_INTERVAL = '30s'
        GITHUB_TOKEN = credentials('github-token')
        TRIVY_RESULTS_FILE = "results\\trivy-results.txt"
        Python_path = "${python}"
        TERRASCAN_PATH = "${terrascan}"
        INFRACOST_PATH = "${infracost}"
        RESULTS_DIR = "${env.WORKSPACE}\\results"
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('CI: Build and Test') {
            stages {
               stage('Create Results Directory') {
                    steps {
                        script {
                            bat """
                                if not exist ${RESULTS_DIR} mkdir ${RESULTS_DIR}
                            """
                        }
                    }
                }
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

                stage('Code Quality Checks') {
                    stages {
                        stage('Flake8') {
                            steps {
                                script {
                                    bat """
                                        ${env.Python_path} -m pip install flake8
                                        ${env.Python_path} -m flake8 . > ${RESULTS_DIR}\\flake8.log || exit 0
                                    """
                                }
                            }
                            post {
                                always {
                                    archiveArtifacts artifacts: "${RESULTS_DIR}\\flake8.log", allowEmptyArchive: true
                                }
                            }
                        }

                        stage('Black') {
                            steps {
                                script {
                                    bat """
                                        ${env.Python_path} -m pip install black
                                        ${env.Python_path} -m black --check . > ${RESULTS_DIR}\\black.log || exit 0
                                    """
                                }
                            }
                            post {
                                always {
                                    archiveArtifacts artifacts: "${RESULTS_DIR}\\black.log", allowEmptyArchive: true
                                }
                            }
                        }

                        stage('Pytest') {
                            steps {
                                script {
                                    bat """
                                        ${env.Python_path} -m pip install pytest
                                        ${env.Python_path} -m pytest --junitxml=${RESULTS_DIR}\\test-results.xml || exit 0
                                    """
                                }
                            }
                            post {
                                always {
                                    archiveArtifacts artifacts: "${RESULTS_DIR}\\test-results.xml", allowEmptyArchive: true
                                }
                            }
                        }
                    }
                }

                stage('Unit Test Coverage') {
                    steps {
                        script {
                            bat """
                                ${env.Python_path} -m pip install coverage
                                ${env.Python_path} -m coverage run -m pytest
                                ${env.Python_path} -m coverage report -m > ${RESULTS_DIR}\\coverage.txt
                                ${env.Python_path} -m coverage xml -o ${RESULTS_DIR}\\coverage.xml
                            """
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: "${RESULTS_DIR}\\coverage.*", allowEmptyArchive: true
                        }
                    }
                }


                stage('Scan Docker Image with Trivy') {
                    steps {
                        script {
                            echo "Scanning Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER} with Trivy"
                            bat """
                                    "${env.TRIVY_PATH}" image --format table --output ${TRIVY_RESULTS_FILE} ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                                    type ${TRIVY_RESULTS_FILE}
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
                        archiveArtifacts artifacts: "${TRIVY_RESULTS_FILE}", allowEmptyArchive: true
                        }
                    }
                }

               

                stage('Security Scanning with Terrascan') {
                    steps {
                        script {
                            dir("${env.TERRAFORM_CONFIG_PATH}") {
                                echo "Running Terrascan to scan Dockerfile, Kubernetes YAML files, and Terraform code"
                                bat """
                                    "${env.TERRASCAN_PATH}" scan -d . -o json > ${RESULTS_DIR}\\terrascan-report.json || exit 0
                                """
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: "${RESULTS_DIR}\\terrascan-report.json", allowEmptyArchive: true
                        }
                    }
                }

                stage('Infrastructure Cost Estimation with Infracost') {
                    steps {
                        dir("${env.TERRAFORM_CONFIG_PATH}") {
                            withCredentials([string(credentialsId: 'infracost-api-key', variable: 'INFRACOST_API_KEY')]) {
                                bat """
                                    echo Running Infracost to estimate infrastructure costs...
                                    "${env.INFRACOST_PATH}" breakdown --path . --show-skipped --out-file ${RESULTS_DIR}\\infracost-report.json || exit 0
                                """
                            }
                        }
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: "${RESULTS_DIR}\\infracost-report.json", allowEmptyArchive: true
                        }
                    }
                }
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

                stage('Push Docker Image to Docker Hub') {
                    steps {
                        script {
                            echo "Pushing Docker image ${DOCKER_IMAGE}:${env.BUILD_NUMBER} to Docker Hub"
                            withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                                bat """
                                echo Logging into Docker Hub...
                                docker login -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%
                                docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                                docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                                docker push ${DOCKER_IMAGE}:latest
                                """
                            }                            
                        }
                    }
                }

                stage('Push Docker Image to GitHub Container Registry') {
                    steps {
                        script {
                            withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                                bat """
                                docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ghcr.io/abdelrahman18036/library-inventory-team3:${env.BUILD_NUMBER}
                                echo ${env.GITHUB_TOKEN} | docker login ghcr.io -u abdelrahman18036 --password-stdin
                                docker push ghcr.io/abdelrahman18036/library-inventory-team3:${env.BUILD_NUMBER}
                                """
                            }
                        }
                    }
                }

                stage('Update Kubernetes Manifests and Push Results') {
                    steps {
                        script {
                            git(url: 'https://github.com/abdelrahman18036/library-inventory-team3.git', branch: 'main', changelog: false, poll: false)

                            bat "powershell -Command \"(Get-Content ${env.WORKSPACE}\\k8s\\deployment.yaml) -replace 'image: .*', 'image: ${DOCKER_IMAGE}:${env.BUILD_NUMBER}' | Set-Content ${env.WORKSPACE}\\k8s\\deployment.yaml\""

                            def hasChanges = bat(script: 'git status --porcelain', returnStatus: true) == 0

                            if (hasChanges) {
                                withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                                    bat """
                                        git config user.name "Jenkins CI"
                                        git config user.email "jenkins@orange.com"
                                        git add ${env.WORKSPACE}\\k8s\\deployment.yaml
                                        git add ${env.WORKSPACE}\\results\\*
                                        git commit -m "Update deployment to use image ${DOCKER_IMAGE}:${env.BUILD_NUMBER} and push results"
                                        git push https://%GITHUB_TOKEN%@github.com/abdelrahman18036/library-inventory-team3.git HEAD:main
                                    """
                                }
                            } else {
                                echo "No changes to commit"
                            }
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
                            // "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus-server-service.yaml -n ${NAMESPACE}
                            // "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\pv-prometheus-alertmanager.yaml -n ${NAMESPACE}
                        }
                    }
                }

                stage('Deploy Grafana and Prometheus') {
                    steps {
                        script {
                            echo "Deploying Grafana to Kubernetes namespace: ${NAMESPACE}"
                            bat """
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus\\prometheus-clusterrole.yaml -n ${NAMESPACE}
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus\\prometheus-clusterrolebinding.yaml -n ${NAMESPACE}
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\monitoring\\prometheus-pvc.yaml -n ${NAMESPACE}
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus\\prometheus-config.yaml -n ${NAMESPACE}
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus\\prometheus-deployment.yaml -n ${NAMESPACE}
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus\\prometheus-service.yaml -n ${NAMESPACE}  
                            """
                            echo "Deploying Grafana to Kubernetes namespace: ${NAMESPACE}"
                            bat """
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\grafana\\grafana-deployment.yaml -n ${NAMESPACE}
                            "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\grafana\\grafana-service.yaml -n ${NAMESPACE}
                            """

                        }
                    }
                }

                // stage('Deploy with Helm') {
                //     steps {
                //         script {
                //             echo "Deploying Helm charts to Kubernetes namespace: ${NAMESPACE}"
                //             bat """
                //                 "${env.HELM_PATH}" repo add prometheus-community https://prometheus-community.github.io/helm-charts
                //                 "${env.HELM_PATH}" repo add grafana https://grafana.github.io/helm-charts
                //                 "${env.HELM_PATH}" repo update

                //                 # Check if Prometheus is already installed
                //                 "${env.HELM_PATH}" status prometheus --namespace ${NAMESPACE} >nul 2>&1 || (
                //                     "${env.HELM_PATH}" install prometheus prometheus-community/prometheus --namespace ${NAMESPACE} --set alertmanager.persistentVolume.enabled=false --set server.persistentVolume.enabled=false --set pushgateway.persistentVolume.enabled=false --set server.global.scrape_interval=${PROMETHEUS_SCRAPE_INTERVAL}
                //                 )

                //                 # Check if Grafana is already installed
                //                 "${env.HELM_PATH}" status grafana --namespace ${NAMESPACE} >nul 2>&1 || (
                //                     "${env.HELM_PATH}" install grafana grafana/grafana --namespace ${NAMESPACE} --set admin.password=${GRAFANA_ADMIN_PASSWORD} --set service.type=LoadBalancer
                //                 )
                //             """
                //         }
                //     }
                // }

                // stage('Apply Kubernetes Manifests') {
                //     steps {
                //         script {
                //             echo "Applying Kubernetes manifests in namespace: ${NAMESPACE}"
                //             bat """
                //                 "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\pv-prometheus-alertmanager.yaml -n ${NAMESPACE}
                //                 "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\prometheus-server-service.yaml -n ${NAMESPACE} --validate=false
                //                 "${env.KUBECTL_PATH}" apply -f ${env.WORKSPACE}\\k8s\\alert-rules.yml -n ${NAMESPACE} --validate=false

                //             """
                //         }
                //     }
                // }


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
