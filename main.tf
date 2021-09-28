provider "kubernetes" {
  host                   = var.kubernetes_cluster_endpoint
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes_cluster_endpoint
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "argo-ns" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "msur"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"

  # We are going to access the console with a port forwarded connection, so we'll disable TLS.
  # This allow us to avoid the self-signed certificate warning for localhosts.
  # controller.extraArgs = ["insecure"]
}