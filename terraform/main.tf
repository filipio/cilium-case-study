terraform {
 required_providers {
  aws = {
   source = "hashicorp/aws"
  }
 }
}

data "aws_iam_roles" "LabRole" {
  name_regex = ".*LabRole.*"
}

locals {
  lab_arn = tolist(data.aws_iam_roles.LabRole.arns)[0]
}

data "aws_subnets" "labSubnets" {
  filter {
    name = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

resource "aws_eks_cluster" "labCluster" {
 name = var.cluster_name
 role_arn = local.lab_arn

 vpc_config {
  subnet_ids = data.aws_subnets.labSubnets.ids
 }
}

resource "aws_eks_node_group" "labNodeGroup" {
cluster_name  = aws_eks_cluster.labCluster.name
node_group_name = "${aws_eks_cluster.labCluster.name}-worker-nodes"
node_role_arn  = local.lab_arn
subnet_ids   = data.aws_subnets.labSubnets.ids
instance_types = [var.node_group_instance_type]

scaling_config {
  desired_size = 2
  max_size   = 2
  min_size   = 2
}
}

resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_node_group.labNodeGroup.cluster_name}"
    }
}

output "result" {
  value = "cluster '${aws_eks_cluster.labCluster.name}' is ready to use. Run 'kubectl get nodes' to verify"
}