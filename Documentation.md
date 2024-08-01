# Documentation for Library Inventory System

This document provides an in-depth overview of the Library Inventory System project, detailing the setup, issues encountered during development, and solutions implemented to resolve those issues. Additionally, it covers the infrastructure and CI/CD pipeline setup, and specific challenges related to the Kubernetes deployment.

## Project Overview

The Library Inventory System is designed to manage books within a library, including adding, updating, borrowing, and returning books. The system uses Flask for the web application, Docker for containerization, Kubernetes for deployment, Prometheus for monitoring, and Jenkins for CI/CD. The infrastructure is provisioned using Terraform.

## Infrastructure Setup

### Terraform

The initial setup of the infrastructure was handled using Terraform. The Terraform configuration included the creation of an Amazon EKS (Elastic Kubernetes Service) cluster, networking components, and other necessary AWS resources. However, we encountered several issues during this process:

1. **Internet Connectivity Issue**:

   - **Problem**: The Kubernetes cluster did not have internet access due to the lack of a NAT Gateway.
   - **Solution**: A NAT Gateway was provisioned, enabling outbound internet access for the Kubernetes nodes in the private subnets.

2. **Availability Zone Fluctuations**:
   - **Problem**: Every time the Terraform configuration was applied, the availability zones for the resources would change, causing instability in the infrastructure.
   - **Solution**: We modified the Terraform code to specify and fix the availability zones, ensuring consistent zone assignments with every deployment.

### Jenkins Pipeline

Despite using Terraform to provision the infrastructure, it was observed that manual intervention was often required, and Terraform alone was not always effective in automating the deployment. Therefore, Jenkins was introduced to handle the CI/CD pipeline and automate the infrastructure and application deployment processes.

### Jenkins Configuration

Jenkins was configured with the following environment variables to automate various steps:

- **DOCKER_IMAGE**: `orange18036/team3-library`
- **DOCKER_CREDENTIALS**: `dockerhub-credentials`
- **KUBECONFIG_PATH**: `kubeconfig`
- **TERRAFORM_EXEC_PATH**: `D:\Programs\terraform.exe`
- **TERRAFORM_CONFIG_PATH**: `${env.WORKSPACE}\terraform`
- **AWS_CLI_PATH**: `D:\Programs\aws.exe`
- **KUBECTL_PATH**: `D:\Programs\kubectl.exe`
- **NAMESPACE**: `team3`
- **TRIVY_PATH**: `D:\Programs\trivy`
- **HELM_PATH**: `D:\Programs\helm.exe`
- **GRAFANA_ADMIN_PASSWORD**: `admin`
- **PROMETHEUS_SCRAPE_INTERVAL**: `30s`

These variables allowed the pipeline to build Docker images, push them to a Docker registry, apply Kubernetes manifests, and deploy the application and monitoring components.

## Application Deployment

### Docker

The application was containerized using Docker, and the following steps were performed:

- **Docker Image Build**: The application was built into a Docker image using the provided `Dockerfile`.
- **Container Deployment**: Docker Compose was used to manage the containerized deployment locally.

### Kubernetes

Kubernetes was used to deploy the application in a clustered environment. Key components included:

- **Deployment**: Managed the scaling and availability of the application pods.
- **Service**: Exposed the application within the cluster and externally via LoadBalancer.
- **Persistent Volumes**: Managed the storage for the application data.

### Monitoring and Alerts

Prometheus was configured to monitor the system and alert on specific metrics. The configuration was handled using Kubernetes ConfigMaps, and the following challenges were addressed:

1. **No Internet Access for Prometheus**:

   - **Problem**: Prometheus could not scrape metrics from certain endpoints due to lack of internet access.
   - **Solution**: Ensured that all necessary services were reachable within the cluster and adjusted the Prometheus configuration accordingly.

2. **Alert Configuration**:
   - Alerts were configured in `alert-rules.yml` and applied through Kubernetes to monitor the health and availability of the application.

## Issues and Resolutions

### Internet Connectivity in Kubernetes

- **Issue**: The Kubernetes cluster lacked internet access because there was no NAT Gateway configured.
- **Resolution**: Provisioned a NAT Gateway in the Terraform configuration to ensure nodes could access the internet for updates and external communications.

### Changing Availability Zones

- **Issue**: The EKS cluster's availability zones would change with each Terraform apply, causing resource instability.
- **Resolution**: Explicitly defined and fixed the availability zones in the Terraform configuration to maintain consistency.

### Terraform Automation Limitations

- **Issue**: While Terraform was used to set up the infrastructure, it required manual intervention and was not always effective for repeated automated deployments.
- **Resolution**: Integrated Jenkins to manage the automation of deployments, leveraging Jenkins' ability to handle more complex workflows and coordinate between Terraform, Docker, and Kubernetes.

## Conclusion

This project demonstrated the use of multiple DevOps tools and practices, including containerization with Docker, orchestration with Kubernetes, infrastructure as code with Terraform, and continuous deployment with Jenkins. While challenges were encountered, solutions were implemented that improved the stability and reliability of the deployment process. The use of Prometheus for monitoring ensured that the system could be effectively managed and maintained.

For any further enhancements or modifications, consult the specific configuration files and adjust them according to the needs of the deployment environment.
