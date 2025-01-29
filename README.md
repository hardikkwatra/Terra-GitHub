### README Documentation

## Infrastructure Overview

This project provisions a cloud infrastructure to support a decentralized application (dApp) with a React frontend, Node.js backend, MongoDB database, Ethereum blockchain integration, and external API services. The infrastructure is designed to be scalable, secure, and maintainable.

## Task 1: Infrastructure Planning

### Architecture Diagram

![Architecture Diagram](link-to-architecture-diagram)

### Required Cloud Resources

Based on the provided architecture diagram, the required cloud resources are:

1. **Compute Layer:**
   - Kubernetes Cluster (EKS/GKE/AKS) or EC2 Instances for:
     - Frontend (React App)
     - Backend (Node.js with Express.js and Ethers.js)
   - Auto Scaling Groups
   - Load Balancers

2. **Database Layer:**
   - MongoDB (Managed or Self-Hosted on VM/K8s)
   - Data persistence and backup policies

3. **Blockchain Integration:**
   - Ethereum Node (Infura/Alchemy or self-hosted via Geth)
   - Connectivity between the backend and the blockchain

4. **External API Services:**
   - API Gateway or a reverse proxy (NGINX) to handle external API calls

5. **Networking & Security:**
   - VPC
   - Subnets
   - Security Groups
   - IAM Roles & Policies for secure access control

6. **CI/CD Integration:**
   - CI/CD pipeline (GitHub Actions, Jenkins, or GitLab CI) for automatic deployment
   - Terraform modules to manage infrastructure updates

## Task 2: Terraform Script Development

### Cloud Resources Provisioned

The following cloud resources are provisioned using Terraform scripts:

1. **Compute Layer:**
   - Kubernetes Cluster (EKS/GKE/AKS) or EC2 Instances for:
     - Frontend (React App)
     - Backend (Node.js with Express.js and Ethers.js)
   - Auto Scaling Groups
   - Load Balancers

2. **Database Layer:**
   - MongoDB (Managed or Self-Hosted on VM/K8s)
   - Data persistence and backup policies

3. **Blockchain Integration:**
   - Ethereum Node (Infura/Alchemy or self-hosted via Geth)
   - Connectivity between the backend and the blockchain

4. **External API Services:**
   - API Gateway or a reverse proxy (NGINX) to handle external API calls

5. **Networking & Security:**
   - VPC
   - Subnets
   - Security Groups
   - IAM Roles & Policies for secure access control

6. **CI/CD Integration:**
   - CI/CD pipeline (GitHub Actions) for automatic deployment
   - Terraform modules to manage infrastructure updates

### Terraform Modules

The Terraform scripts are organized into modules for better modularization, reusability, and readability. Each module is responsible for provisioning a specific part of the infrastructure.

#### Modules:
- **Compute Layer Module:** Provisions Kubernetes Cluster or EC2 Instances, Auto Scaling Groups, and Load Balancers.
- **Database Layer Module:** Provisions MongoDB with data persistence and backup policies.
- **Blockchain Integration Module:** Provisions Ethereum Node and ensures connectivity with the backend.
- **External API Services Module:** Sets up API Gateway or NGINX reverse proxy.
- **Networking & Security Module:** Implements VPC, Subnets, Security Groups, and IAM Roles & Policies.
- **CI/CD Integration Module:** Defines CI/CD pipeline for automatic deployment and infrastructure updates.

### Usage

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the Terraform scripts:
   ```bash
   terraform apply
   ```

### Conclusion

This project demonstrates a comprehensive approach to provisioning a cloud infrastructure for a decentralized application. The Terraform scripts are modular, follow best practices, and ensure a secure and scalable environment. The CI/CD pipeline automates the deployment process, making it easier to manage infrastructure updates.
