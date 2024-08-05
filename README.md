# Library Inventory System

This project is a comprehensive Library Inventory System designed to manage books within a library, including adding, updating, borrowing, and returning books. The system is containerized using Docker, deployed on Kubernetes, and monitored with Prometheus and Grafana. The infrastructure is provisioned using Terraform, and a CI/CD pipeline is managed with Jenkins.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Running the Application Locally](#running-the-application-locally)
- [Deployment](#deployment)
  - [Docker](#docker)
  - [Kubernetes](#kubernetes)
  - [Terraform](#terraform)
  - [CI/CD with Jenkins](#cicd-with-jenkins)
- [Monitoring and Alerts](#monitoring-and-alerts)
  - [Prometheus Setup](#prometheus-setup)
  - [Creating Alerts](#creating-alerts)
- [Project Completion Checklist](#project-completion-checklist)
  - [Minimum Requirements](#minimum-requirements)
  - [Bonus](#bonus)
  - [Extra Bonuses](#extra-bonuses)
- [Screenshots and Explanations](#screenshots-and-explanations)
- [Full Documentation](#full-documentation)
- [Process Flow Diagram](#process-flow-diagram)
- [License](#license)

## Getting Started

### Prerequisites

To get started with the Library Inventory System, ensure you have the following tools and technologies installed:

- **Python 3.10+**: Required for running the Flask web application.
- **Docker**: Containerizes the application to simplify deployment.
- **Kubernetes**: Manages containerized applications in a clustered environment.
- **Terraform**: Provisions and manages AWS infrastructure, including EKS.
- **AWS CLI**: Interacts with AWS services directly from the command line.
- **Jenkins**: Automates the CI/CD pipeline for building, testing, and deploying the application.
- **Prometheus**: Monitors application metrics and provides alerting.
- **Grafana**: Visualizes metrics collected by Prometheus.
- **Trivy**: Scans Docker images for vulnerabilities to ensure secure deployments.
- **Terrascan**: Scans Terraform configurations for security and compliance.
- **Infracost**: Estimates and manages cloud infrastructure costs.

### Installation

Follow these steps to set up the project:

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/library-inventory-system.git
   cd library-inventory-system
   ```

2. **Install Python dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Running the Application Locally

To run the application on your local machine:

1. **Start the Flask application**:

   ```bash
   python app.py
   ```

2. **Access the application**:

   Open your browser and navigate to `http://localhost:5000`.

## Deployment

### Docker

1. **Build the Docker image**:

   ```bash
   docker build -t library-inventory .
   ```

2. **Run the Docker container**:

   ```bash
   docker-compose up
   ```

3. **Access the application**:

   Open your browser and navigate to `http://localhost:5000`.

### Kubernetes

1. **Deploy the application on Kubernetes**:

   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   kubectl apply -f k8s/persistent-volume.yaml
   kubectl apply -f k8s/persistent-volume-claim.yaml
   ```

2. **Deploy Prometheus and AlertManager**:

   ```bash
   kubectl apply -f k8s/prometheus-server-service.yaml
   kubectl apply -f k8s/pv-prometheus-alertmanager.yaml
   kubectl apply -f k8s/alert-rules.yml
   ```

3. **Check the status of your Kubernetes resources**:

   ```bash
   kubectl get all -n team3
   ```

4. **Access Prometheus**:

   Access Prometheus via the LoadBalancer IP or DNS:

   ```url
   http://<LoadBalancer-IP>:9090
   ```

### Terraform

1. **Initialize Terraform**:

   ```bash
   cd terraform
   terraform init
   ```

2. **Apply the Terraform configuration**:

   ```bash
   terraform apply
   ```

   This command will set up the necessary infrastructure on AWS, including an EKS cluster for deploying the application.

### CI/CD with Jenkins

The project includes a `Jenkinsfile` that defines the CI/CD pipeline for building, testing, and deploying the application.

1. **Setup Jenkins**:

   - Install Jenkins on your server or use Jenkins in a Docker container.
   - Install necessary plugins:
     - Docker Pipeline
     - Kubernetes Plugin
     - Pipeline: AWS Steps
     - GitHub Integration
     - Trivy
     - Terrascan
     - Infracost
   - Configure Jenkins to connect to your GitHub repository.

2. **Pipeline Stages Overview**:

   The `Jenkinsfile` automates the following stages:

   - **Checkout**: Pulls the latest code from the GitHub repository.
   - **Build Docker Image**: Builds the Docker image for the application.
   - **Push Docker Image**: Pushes the Docker image to DockerHub and GitHub Container Registry (ghcr.io).
   - **Security Scanning**: Uses Trivy for Docker image vulnerability scanning and Terrascan for Terraform configuration scanning.
   - **Cost Estimation**: Utilizes Infracost for estimating and managing infrastructure costs.
   - **Deploy to Kubernetes**: Deploys the application to the Kubernetes cluster using `kubectl`.
   - **Monitor & Alert Setup**: Deploys Prometheus and Grafana for monitoring and sets up alert rules.

3. **Trigger the Pipeline**:

   - Once set up, every push to the repository can trigger the pipeline.
   - The pipeline automatically builds, tests, and deploys the application to your Kubernetes cluster.

## Monitoring and Alerts

### Prometheus Setup

1. **Deploy Prometheus using the provided configurations**:

   ```bash
   kubectl apply -f k8s/prometheus-server-service.yaml
   ```

2. **Access Prometheus**:

   Access Prometheus via the LoadBalancer IP or DNS:

   ```url
   http://<LoadBalancer-IP>:9090
   ```

### Creating Alerts

1. **Edit `alert-rules.yml` to define alerting rules**:

   ```yaml
   groups:
     - name: example
       rules:
         - alert: InstanceDown
           expr: up == 0
           for: 5m
           labels:
             severity: critical
           annotations:
             summary: "Instance {{ $labels.instance }} down"
             description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."
   ```

2. **Apply the updated ConfigMap**:

   ```bash
   kubectl create configmap prometheus-server --from-file=alert-rules.yml --from-file=prometheus.yml -n team3 --dry-run=client -o yaml | kubectl apply -f -
   ```

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

## Screenshots and Explanations

### Complete Test Overview

![Complete Test](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/complete_test.png "Complete Test Overview")

This screenshot shows the successful completion of all test cases, ensuring the application's stability before deployment.

### Jenkins Deployment on EC2

![Deploy Jenkins on EC2](https://raw.githubusercontent.com/abdelrahman18036/library-inventory-team3/main/screenshots/deploy_jenkins_on_ec2.png "Jenkins Deployment on EC2")

This image captures the deployment of Jenkins on an EC2 instance, a

crucial part of managing the CI/CD pipeline.

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

## Full Documentation

For full details on the project, please refer to the **[Documentation.md](Documentation.md)** file.

## Process Flow Diagram

```mermaid
graph TD;
    A[GitHub (Code Push)] --> B[Jenkins (Trigger Pipeline)];
    B --> C[Checkout Code];
    C --> D[Build Docker Image];
    D --> E[Code Quality Checks];
    E --> E1[Flake8];
    E --> E2[Black];
    E --> E3[Pytest];
    D --> F[Unit Test Coverage (Coverage)];
    F --> G[Security Scanning];
    G --> G1[Trivy];
    G --> G2[Terrascan];
    F --> H[Infrastructure Cost Estimation (Infracost)];
    H --> I[Push Docker Image];
    I --> I1[DockerHub (Image Storage)];
    I --> I2[GHCR (Image Storage)];
    I --> J[Deploy to AWS EKS (Kubernetes)];
    J --> K[AWS VPC (Virtual Private Cloud)];
    K --> L[AWS EC2 (Kubernetes Nodes)];
    L --> M[AWS Load Balancer];
    M --> N[Apply Kubernetes Manifests];
    N --> O[Deploy Application on AWS EKS Cluster];
    O --> P[Deploy Prometheus & Grafana];
    P --> P1[Prometheus (Monitoring)];
    P --> P2[Grafana (Visualization)];
```

## License

This project is licensed under the MIT License.
