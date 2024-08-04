# Library Inventory System

This project is a comprehensive Library Inventory System designed to manage books within a library, including adding, updating, borrowing, and returning books. It includes infrastructure setup using Terraform, deployment configurations in Kubernetes, monitoring setup with Prometheus, and CI/CD pipeline configuration using Jenkins.

## Getting Started

### Prerequisites

- **Python 3.10+**: Required for running the Flask web application. Ensure that you have Python 3.10 or higher installed to support all dependencies.
- **Docker**: Used to containerize the application. Docker simplifies the deployment process by packaging the application and its dependencies into a single container image.
- **Kubernetes**: For deploying the application in a clustered environment. Kubernetes manages containerized applications across a cluster of machines, ensuring high availability and scalability.
- **Terraform**: To provision and manage AWS infrastructure, including setting up an EKS (Elastic Kubernetes Service) cluster. Terraform enables infrastructure as code, allowing for automated and consistent provisioning.
- **AWS CLI**: Required for interacting with AWS services. The AWS CLI allows you to manage AWS resources directly from the command line.
- **Jenkins**: For setting up and managing CI/CD pipelines. Jenkins automates the build, test, and deployment processes, facilitating continuous integration and continuous deployment.
- **Prometheus**: Used for monitoring and alerting. Prometheus collects metrics from configured endpoints and stores them in a time-series database, providing powerful querying capabilities and alerting.
- **Grafana**: For visualizing metrics collected by Prometheus. Grafana provides a rich set of visualization options for creating dashboards and monitoring the application's performance.
- **Trivy**: For vulnerability scanning of Docker images to ensure they are secure before deployment.
- **Terrascan**: For security and compliance scanning of Terraform configurations.
- **Infracost**: For estimating and managing cloud infrastructure costs.

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/library-inventory-system.git
   cd library-inventory-system
   ```

````

2. **Install Python dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Run the application locally

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

   This will set up the necessary infrastructure on AWS, including an EKS cluster for deploying the application.

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

2. **Jenkinsfile Explanation**:

   The `Jenkinsfile` is designed to automate the build, test, and deployment process. Below is a high-level overview of the stages:

   ```groovy
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
           TRIVY_PATH = '${TRIVY}'
           HELM_PATH = '${HELM}'
           GRAFANA_ADMIN_PASSWORD = 'admin'
           PROMETHEUS_SCRAPE_INTERVAL = '30s'
           INFRACOST_PATH = '${INFRACOST}'
       }
   }
   ```

   **Pipeline Stages**:

   - **Checkout**: Pulls the latest code from the GitHub repository.
   - **Build Docker Image**: Builds the Docker image for the application.
   - **Push Docker Image**: Pushes the Docker image to a Docker registry and GitHub Container Registry (ghcr.io).
   - **Security Scanning**: Runs Trivy to scan Docker images for vulnerabilities and Terrascan to scan Terraform configurations for security compliance.
   - **Cost Estimation**: Uses Infracost to estimate and manage infrastructure costs.
   - **Deploy to Kubernetes**: Deploys the application to the Kubernetes cluster using `kubectl`.
   - **Monitor & Alert Setup**: Deploys Prometheus and Grafana for monitoring and sets up alert rules.

3. **Trigger the Pipeline**:

   - Once the Jenkinsfile is set up, every push to the repository can trigger the pipeline.
   - The pipeline will automatically build, test, and deploy the application to your Kubernetes cluster.

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

## Full Documentation

For full details on the project, please refer to the **[Documentation.md](Documentation.md)** file.

## License

This project is licensed under the MIT License.

```

### Summary of Updates:
- **Security Scanning**: Mentioned Trivy and Terrascan usage in the pipeline.
- **Cost Estimation**: Mentioned Infracost for cost management.
- **Push to GitHub Container Registry**: Included in the Docker image push step.
- **Pipeline Stages**: Updated to reflect all stages from the Jenkinsfile.

This `README.md` provides a comprehensive overview of the project setup, including additional steps and tools used in the Jenkins pipeline.

````
