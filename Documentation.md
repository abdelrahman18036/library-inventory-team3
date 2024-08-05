# Documentation for Library Inventory System

This document provides an in-depth overview of the Library Inventory System project, detailing the setup, issues encountered during development, and solutions implemented to resolve those issues. Additionally, it covers the infrastructure and CI/CD pipeline setup, and specific challenges related to the Kubernetes deployment.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Completion Checklist](#project-completion-checklist)
  - [Minimum Requirements](#minimum-requirements)
  - [Bonus](#bonus)
  - [Extra Bonuses](#extra-bonuses)
- [Terraform Deployment Steps](#terraform-deployment-steps)
- [Results Analysis and Actions](#results-analysis-and-actions)
  - [Coverage Report (coverage.txt)](#1-coverage-report-coveragetxt)
  - [Flake8 Linting Report (flake8.log)](#2-flake8-linting-report-flake8log)
  - [Infracost Report (infracost-reportjson)](#3-infracost-report-infracost-reportjson)
  - [Terrascan Security Report (terrascan-reportjson)](#4-terrascan-security-report-terrascan-reportjson)
  - [Trivy Vulnerability Scan (trivy-results.txt)](#5-trivy-vulnerability-scan-trivy-resultstxt)
- [Infrastructure Setup Challenges](#infrastructure-setup-challenges)
  - [Terraform](#terraform)
  - [Jenkins Pipeline](#jenkins-pipeline)
  - [Jenkins Configuration](#jenkins-configuration)
  - [GitOps and Continuous Deployment](#gitops-and-continuous-deployment)
  - [Package Management and Dependencies](#package-management-and-dependencies)
- [Application Deployment](#application-deployment)
  - [Docker](#docker)
  - [Kubernetes](#kubernetes)
  - [Monitoring and Alerts](#monitoring-and-alerts)
- [Issues and Resolutions](#issues-and-resolutions)
  - [Internet Connectivity in Kubernetes](#internet-connectivity-in-kubernetes)
  - [Changing Availability Zones](#changing-availability-zones)
  - [Terraform Automation Limitations](#terraform-automation-limitations)
  - [Security Scanning with Terrascan](#security-scanning-with-terrascan)
  - [Cost Management with Infracost](#cost-management-with-infracost)
- [Screenshots and Explanations](#screenshots-and-explanations)
- [Conclusion](#conclusion)
- [Project Structure](#project-structure)
- [File Sturcture](#file-sturcture)
- [License](#license)

## Project Overview

The Library Inventory System is designed to manage books within a library, including adding, updating, borrowing, and returning books. The system utilizes Flask for the web application, Docker for containerization, Kubernetes for deployment, Prometheus for monitoring, and Jenkins for CI/CD automation. The infrastructure is provisioned using Terraform.

## Project Completion Checklist

### Minimum Requirements

- **Application Development using Flask, Python** ✔️
- **Dockerization using Docker** ✔️
- **Infrastructure as Code with Terraform** ✔️
- **Kubernetes Deployment on EKS** ✔️
- **CI/CD Pipeline Setup using Jenkins** ✔️
- **Documentation and Presentation using Markdown, Git** ✔️

### Bonus

- **Monitoring and Logging using Prometheus, Grafana** ✔️

### Extra Bonuses

- **Automated Tagging:** Auto-update the deployment file with the latest Docker image tag after build using Jenkins, Docker ✔️
- **Continuous Integration:** Implemented live webhook to trigger Jenkins pipeline automatically using Jenkins, GitHub Webhooks ✔️
- **Container Registry:** Push Docker image to GitHub Container Registry using GitHub Container Registry (ghcr.io) ✔️
- **GitOps Integration:** Automate and manage deployment configurations using GitOps practices using Git, Jenkins ✔️
- **Code Quality Assurance:** Integrated code quality checks using Flake8, Black, Pytest ✔️
- **Unit Testing with Coverage:** Implemented unit tests with code coverage reporting using Coverage ✔️
- **Security and Compliance:** Implemented security scanning using Terrascan, Trivy ✔️
- **Cost Management:** Integrated infrastructure cost estimation using Infracost ✔️
- **Super Slim Docker Image:** Reduced Docker image size to just 19 MB using SlimToolkit ✔️
- **Terraform Moduling:** Organized Terraform configurations into reusable modules for better maintainability and scalability ✔️

## Terraform Deployment Steps

To deploy the infrastructure using Terraform, follow these steps:

1. **Initialize Terraform:**
   Ensure you are in the `terraform` directory and run the initialization command:

   ```sh
   terraform init
   ```

2. **Review Terraform Plan:**
   To see the changes Terraform will make to your infrastructure, run:

   ```sh
   terraform plan
   ```

   This step is crucial for understanding what resources will be created, modified, or destroyed.

3. **Apply Terraform Configuration:**
   Once you are satisfied with the plan, apply the configuration to provision the resources:

   ```sh
   terraform apply
   ```

   Confirm the action when prompted. This will create the necessary AWS resources for your project.

4. **Verify Deployment:**
   After the deployment, ensure that the AWS resources (EKS cluster, EC2 instances, NAT Gateway, etc.) are properly set up by checking the AWS Management Console.

5. **Post-Deployment Checks:**
   - **EKS Cluster:** Verify that the EKS cluster is running and properly connected.
   - **NAT Gateway:** Ensure the NAT Gateway provides the necessary internet connectivity.
   - **Security Groups:** Check the security groups for any open ports and review them against your security policies.

---

## Results Analysis and Actions

### **1. Coverage Report (coverage.txt)**

This file provides insights into the code coverage of your test cases.

- **Key Actions:**

  - **Analyze Missing Coverage:** Identify the lines of code that are not covered by tests and consider adding test cases to increase coverage.
  - **Target High-Impact Areas:** Focus on critical paths in your application to ensure they are well-tested.

- **Example:**
  - `app.py`: 43 out of 121 statements are missing coverage. Consider adding tests for functions and conditional paths in these areas.
  - `tests/test_library_app.py`: Although this file itself is a test file, some parts of the tests are not being executed. Make sure the tests are comprehensive.

### **2. Flake8 Linting Report (flake8.log)**

This log details code style issues detected by Flake8.

- **Key Actions:**
  - **Fix Long Lines:** Several lines exceed the recommended 79-character limit (`E501`). Consider breaking these lines or refactoring the code for better readability.
  - **Trailing Whitespace and Blank Lines:** Remove any unnecessary trailing whitespace and extra blank lines (`W291`, `W293`).
  - **Code Cleanliness:** Resolve any other issues like trailing whitespace to adhere to PEP 8 standards.

### **3. Infracost Report (infracost-report.json)**

This report gives a breakdown of the estimated costs of your infrastructure.

- **Key Actions:**

  - **Review High-Cost Resources:** Focus on resources with significant costs, such as the EKS cluster and NAT Gateway. Consider optimization strategies like using reserved instances or rightsizing resources.
  - **Monitor Data Processing Costs:** If the project involves large data transfers, monitor the usage and explore cost-saving options like S3 for storage or data transfer acceleration.

- **Example:**

  - **EKS Cluster Cost:** At $73 per month, the EKS cluster is a major cost driver. Evaluate if the workload justifies this expense.
  - **NAT Gateway:** Costs $32.85 per month. Ensure it’s necessary for your architecture and consider using a smaller, less costly configuration if possible.

  access due to the absence of a NAT Gateway.

  - **Solution**: A NAT Gateway was provisioned, enabling outbound internet access for Kubernetes nodes in the private subnets.

2. **Availability Zone Fluctuations**:
   - **Problem**: Each Terraform apply caused changes in the availability zones, leading to infrastructure instability.
   - **Solution**: Terraform configuration was modified to specify and fix availability zones, ensuring consistent resource deployment.

### Jenkins Pipeline

To automate infrastructure provisioning and application deployment, Jenkins was introduced for CI/CD pipeline management.

### Jenkins Configuration

Jenkins was configured with environment variables to streamline various stages of the pipeline:

- **DOCKER_IMAGE**: `orange18036/team3-library`
- **DOCKER_CREDENTIALS**: `dockerhub-credentials`
- **KUBECONFIG_PATH**: `kubeconfig`
- **TERRAFORM_EXEC_PATH**: `${env.WORKSPACE}\terraform`
- **AWS_CLI_PATH**: `${aws}`
- **KUBECTL_PATH**: `${kubectl}`
- **NAMESPACE**: `team3`
- **TRIVY_PATH**: `${trivy}`
- **HELM_PATH**: `${helm}`
- **GRAFANA_ADMIN_PASSWORD**: `admin`
- **PROMETHEUS_SCRAPE_INTERVAL**: `30s`

These variables enabled the pipeline to build Docker images, push them to a registry, apply Kubernetes manifests, and deploy the application and monitoring components.

### GitOps and Continuous Deployment

GitOps practices were integrated to further automate and track changes in infrastructure and application configurations. The deployment pipeline automatically applied changes from the repository to the Kubernetes cluster, ensuring consistent and traceable deployments.

### Package Management and Dependencies

Dependencies were managed as follows:

- **Python Dependencies**: Managed using `pip` and listed in the `requirements.txt`.
- **Docker Images**: Containerized application dependencies to ensure environment consistency.
- **Terraform Modules**: Reusable Terraform modules managed infrastructure components.
- **Kubernetes Manifests**: Defined deployment, service, ingress, and other resources.

## Application Deployment

### Docker

The application was containerized using Docker. Key steps included:

- **Docker Image Build**: The application was built into a Docker image using the provided `Dockerfile`.
- **Container Deployment**: Managed locally using Docker Compose.

### Kubernetes

Kubernetes was used to deploy the application in a clustered environment. Key components included:

- **Deployment**: Managed the scaling and availability of application pods.
- **Service**: Exposed the application within the cluster and externally via LoadBalancer.
- **Persistent Volumes**: Managed storage for application data.

### Monitoring and Alerts

Prometheus was configured to monitor the system and send alerts based on specific metrics.

**Challenges and Solutions:**

1. **No Internet Access for Prometheus**:

   - **Problem**: Prometheus couldn't scrape metrics from certain endpoints due to lack of internet access.
   - **Solution**: Ensured all necessary services were reachable within the cluster and adjusted Prometheus configuration accordingly.

2. **Alert Configuration**:
   - **Problem**: Configuring effective alerts to catch critical issues without creating noise.
   - **Solution**: Alerts were configured in `alert-rules.yml`, focusing on critical metrics to monitor the application's health.

## Issues and Resolutions

### Internet Connectivity in Kubernetes

- **Issue**: Lack of internet access due to no NAT Gateway.
- **Resolution**: Provisioned a NAT Gateway to ensure nodes could access the internet.

### Changing Availability Zones

- **Issue**: Availability zones changed with each Terraform apply, causing resource instability.
- **Resolution**: Fixed availability zones in the Terraform configuration for consistent deployment.

### Terraform Automation Limitations

- **Issue**: Manual intervention was needed despite using Terraform for infrastructure setup.
- **Resolution**: Integrated Jenkins to handle complex workflows and coordinate between Terraform, Docker, and Kubernetes.

### Security Scanning with Terrascan

- **Issue**: Security vulnerabilities were identified in Terraform configurations.
- **Resolution**: Implemented Terrascan in the CI/CD pipeline to ensure compliance with security best practices.

### Cost Management with Infracost

- **Issue**: Managing and optimizing cloud infrastructure costs.
- **Resolution**: Integrated Infracost in the CI/CD pipeline to estimate and review infrastructure costs before deployment.

## Screenshots and Explanations

### Complete Test Overview

![Complete Test](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/complete_test.png "Complete Test Overview")

This screenshot shows the successful completion of all test cases, ensuring the application's stability before deployment.

### Jenkins Deployment on EC2

![Deploy Jenkins on EC2](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/deploy_jenkins_on_ec2.png "Jenkins Deployment on EC2")

This image captures the deployment of Jenkins on an EC2 instance, a crucial part of managing the CI/CD pipeline.

### Grafana Dashboard

![Grafana Dashboard](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/grafan.png "Grafana Dashboard")

The Grafana dashboard provides a comprehensive view of the application's metrics, allowing real-time monitoring of system health.

### Infracost Pull Request Integration

![Infracost Pull Request](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/Infracost_pull_request.png "Infracost Pull Request Integration")

This image demonstrates the integration of Infracost with pull requests, ensuring cost-effective infrastructure changes.

### Prometheus Alerts

![Prometheus Alerts](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/promuthues_alert.png "Prometheus Alerts")

Prometheus alerting is configured to notify the team in case of critical issues, allowing for quick response and resolution.

### Git Push from Jenkins

![Push from Jenkins Git](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/push_from_jenkins_git.png "Git Push from Jenkins")

This image captures the Jenkins pipeline stage where code changes are pushed to the Git repository, ensuring version control.

### Update Docker Tag Name with Jenkins

![Update Docker Tag Name with Jenkins](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/update_dockertagname_withjenkins.png "Update Docker Tag Name with Jenkins")

This image illustrates the process of updating the Docker tag name during Jenkins pipeline execution, ensuring unique tagging for each build.

## Minimize Docker Size to 19 MB

![Minimize Docker Size to 19 MB](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/docker.png "Minimize Docker Size to 19 MB")

## Conclusion

This project demonstrated the integration of multiple DevOps tools and practices, including containerization with Docker, orchestration with Kubernetes, infrastructure as code with Terraform, and continuous deployment with Jenkins. By adopting GitOps practices, the project ensured automated and consistent deployments. Challenges such as internet connectivity issues, fluctuating availability zones, and security concerns were effectively managed through thoughtful configuration and automation.

For further enhancements or modifications, consult the specific configuration files and adjust them according to the needs of the deployment environment.

## Project Structure

The project is structured as follows:

- **app/**: Contains the Flask application code.
- **terraform/**: Terraform configuration files for provisioning infrastructure.
- **k8s/**: Kubernetes manifests for deploying the application and monitoring tools.
- **jenkins/**: Jenkins pipeline configurations and scripts.
- **results/**: Directory to store the output of various pipeline stages, including test results, coverage reports, and scan results.
- **Dockerfile**: Dockerfile for building the application container image.
- **Jenkinsfile**: Jenkins pipeline definition file.
- **requirements.txt**: Python dependencies for the Flask application.

## File Sturcture

│ .dockerignore
│ .gitignore
│ app.py
│ Dockerfile
│ Documentation.md
│ Jenkinsfile
│ Linuxenkinsfile
│ README.md
│ requirements.txt
│
├───data
│ library.json
│
├───k8s
│ │ deployment.yaml
│ │ ingress.yaml
│ │ persistent-volume-claim.yaml
│ │ persistent-volume.yaml
│ │ replicaset.yaml
│ │ service.yaml
│ │
│ ├───grafana
│ │ grafana-deployment.yaml
│ │ grafana-service.yaml
│ │
│ ├───monitoring
│ │ grafana-pvc.yaml
│ │ prometheus-pvc.yaml
│ │
│ └───prometheus
│ prometheus-clusterrole.yaml
│ prometheus-clusterrolebinding.yaml
│ prometheus-config.yaml
│ prometheus-deployment.yaml
│ prometheus-service.yaml
│
├───results
│ black.log
│ coverage.txt
│ flake8.log
│ infracost-report.json
│ terrascan-report.json
│ test-results.xml
│ trivy-results.txt
│
├───screenshots
│ complete_test.png
│ deploy_jenkins_on_ec2.png
│ grafan.png
│ Infracost.png
│ Infracost_pull_request.png
│ promuthues_alert.png
│ push_from_jenkins_git.png
│ terrascan.png
│ update_dockertagname_withjenkins.png
│
├───static
│ custom.css
│
├───templates
│ 400.html
│ 404.html
│ add_book.html
│ base.html
│ borrow_book.html
│ index.html
│ return_book.html
│ search_book.html
│ update_book.html
│
├───terraform
│ │ main.tf
│ │ outputs.tf
│ │ providers.tf
│ │ s3.tf
│ │ variables.tf
│ │
│ └───modules
│ ├───ec2
│ │ main.tf
│ │ outputs.tf
│ │ variables.tf
│ │
│ ├───eks
│ │ main.tf
│ │ outputs.tf
│ │ variables.tf
│ │
│ └───vpc
│ main.tf
│ outputs.tf
│ variables.tf
│
├───tests
│ test_library_app.py

## License

This project is licensed under the MIT License.
