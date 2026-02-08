terraform {
  backend "s3" {
    bucket         = "my-eks-terraform-state-02c39611" 
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}