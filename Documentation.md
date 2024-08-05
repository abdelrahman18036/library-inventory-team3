# Documentation for Library Inventory System

This document provides an in-depth overview of the Library Inventory System project, detailing the setup, issues encountered during development, and solutions implemented to resolve those issues. Additionally, it covers the infrastructure and CI/CD pipeline setup, and specific challenges related to the Kubernetes deployment.

## Project Overview

The Library Inventory System is designed to manage books within a library, including adding, updating, borrowing, and returning books. The system utilizes Flask for the web application, Docker for containerization, Kubernetes for deployment, Prometheus for monitoring, and Jenkins for CI/CD automation. The infrastructure is provisioned using Terraform.

# Project Completion Checklist

## Minimum Requirements

- Application Development using Flask, Python ✔️
- Dockerization using Docker ✔️
- Infrastructure as Code with Terraform using Terraform ✔️
- Kubernetes Deployment on EKS using Kubernetes, AWS EKS ✔️
- CI/CD Pipeline Setup using Jenkins ✔️
- Documentation and Presentation using Markdown, Git ✔️

## Bonus

- Monitoring and Logging using Prometheus, Grafana ✔️

## Extra Bonuses

- Automated Tagging: Auto-update the deployment file with the latest Docker image tag after build using Jenkins, Docker ✔️
- Continuous Integration: Implemented live webhook to trigger Jenkins pipeline automatically using Jenkins, GitHub Webhooks ✔️
- Container Registry: Push Docker image to GitHub Container Registry using GitHub Container Registry (ghcr.io) ✔️
- GitOps Integration: Automate and manage deployment configurations using GitOps practices using Git, Jenkins ✔️
- Code Quality Assurance: Integrated code quality checks using Flake8, Black, Pytest ✔️
- Security and Compliance: Implemented security scanning using Terrascan, Trivy ✔️
- Cost Management: Integrated infrastructure cost estimation using Infracost ✔️

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

### **4. Terrascan Security Report (terrascan-report.json)**

This JSON file lists security issues found in your Terraform configuration.

- **Key Actions:**

  - **Resolve High Severity Issues:** Focus on issues with HIGH severity, such as open SSH ports and unrestricted security groups.
  - **Implement Best Practices:** Ensure that security groups are configured to allow the minimum necessary access, and that IMDSv2 is enforced for EC2 instances.

- **Example:**
  - **Port 22 Open to Internet:** This is a critical issue that needs immediate attention. Restrict SSH access to specific IPs or through a VPN.
  - **IMDSv2:** Enforce IMDSv2 to enhance the security of your EC2 instances.

### **5. Trivy Vulnerability Scan (trivy-results.txt)**

This report contains the vulnerabilities found in your Docker image.

- **Key Actions:**

  - **Upgrade Vulnerable Packages:** Address CRITICAL and HIGH severity vulnerabilities by upgrading to the fixed versions listed.
  - **Rebuild and Rescan:** After upgrading, rebuild your Docker image and run Trivy again to ensure that vulnerabilities are resolved.

- **Example:**
  - **CVE-2021-36159 in apk-tools:** Upgrade `apk-tools` to version `2.12.6-r0` to resolve this critical vulnerability.
  - **Multiple Issues in busybox:** Upgrade `busybox` to version `1.33.1-r6` or higher to address multiple HIGH severity vulnerabilities.

---

## Infrastructure Setup Challenges

### Terraform

The infrastructure was provisioned using Terraform, automating the creation of an Amazon EKS (Elastic Kubernetes Service) cluster, networking components, and other AWS resources.

**Key Challenges and Solutions:**

1. **Internet Connectivity Issue**:

   - **Problem**: The Kubernetes cluster lacked internet access due to the absence of a NAT Gateway.
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
- **TERRAFORM_EXEC_PATH**: `${env.WORKSPACE}\\terraform`
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

## Conclusion

This project demonstrated the integration of multiple DevOps tools and practices, including containerization with Docker, orchestration with Kubernetes, infrastructure as code with Terraform, and continuous deployment with Jenkins. By adopting GitOps practices, the project ensured automated and consistent deployments. Challenges such as internet connectivity issues, fluctuating availability zones, and security concerns were effectively managed through thoughtful configuration and automation.

For further enhancements or modifications, consult the specific configuration files and adjust them according to the needs of the deployment environment.

## Project Structure

## License

This project is licensed under the MIT License.
