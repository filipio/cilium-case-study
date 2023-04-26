## Requirements

- [Terraform](https://www.terraform.io/) installed, verify by command  
  `terraform --version`
- [aws-cli](https://aws.amazon.com/cli/) installed and setup with learner lab, verify by command  
  `aws iam list roles`

## Initialization

Run command  
`terraform init`

## Useful commands

Commands needs to be run in current (`<project_root>/terraform`) directory.

`terraform plan` - check what resources will be created after `terraform apply`  
`terraform apply` - create resources defined in `main.tf`  
`terraform destroy` - destroy previously created resources

NOTE : after running `terraform apply` kubectl is ready to use with EKS,
check it by running  
`kubectl get nodes`
