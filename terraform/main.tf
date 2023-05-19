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
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

resource "aws_eks_cluster" "labCluster" {
  name     = var.cluster_name
  role_arn = local.lab_arn

  vpc_config {
    subnet_ids = data.aws_subnets.labSubnets.ids
  }


}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.labCluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.labCluster.name
  addon_name   = "kube-proxy"
}

resource "null_resource" "kubectl" {
  triggers = {
    node_group_arn = aws_eks_cluster.labCluster.arn
  }

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.labCluster.name}"
  }
}

resource "null_resource" "aws-deamonset-deletion" {
  depends_on = [
    null_resource.kubectl
  ]

  provisioner "local-exec" {
    command = "kubectl -n kube-system delete daemonset aws-node"
  }
}

resource "null_resource" "helm-repo" {
  depends_on = [
    null_resource.aws-deamonset-deletion
  ]

  provisioner "local-exec" {
    command = "helm repo add cilium https://helm.cilium.io/"
  }
}

resource "null_resource" "cilium" {
  depends_on = [
    null_resource.helm-repo
  ]

  provisioner "local-exec" {
    command = "helm install cilium cilium/cilium --namespace kube-system"
  }
}

resource "aws_eks_node_group" "labNodeGroup" {
  cluster_name    = aws_eks_cluster.labCluster.name
  node_group_name = "${aws_eks_cluster.labCluster.name}-worker-nodes"
  node_role_arn   = local.lab_arn
  subnet_ids      = data.aws_subnets.labSubnets.ids
  instance_types  = [var.node_group_instance_type]

  scaling_config {
    desired_size = 4
    max_size     = 5
    min_size     = 3
  }

  depends_on = [
    null_resource.cilium
  ]
}


output "result" {
  value = "cluster '${aws_eks_cluster.labCluster.name}' is set up with cilium. Run 'kubectl -n kube-system get pods' to verify"
}