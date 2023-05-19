## Requirements

- [Terraform](https://www.terraform.io/) installed, verify by command  
  `terraform --version`
- [aws-cli](https://aws.amazon.com/cli/) installed and setup with learner lab, verify by command  
  `aws iam list roles`
- [helm](https://helm.sh/docs/intro/install/) installed, verify by command  
  `helm version`
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) installed, verify by command  
  `kubectl version`

## Setup

1. If running for the first time, initialize terraform:  
   `terraform init`

2. Run below command to create EKS with cilium and connect kubectl to kubernetes cluster:  
   `terraform apply -auto-approve`

3. Verify everything is OK by running:  
   `kubectl -n kube-system get pods`

## Clean up

1. Run below to destroy all created resources:  
   `terraform destroy -auto-approve`  
   NOTE: you need to wait for completion. Then destroy learner lab
