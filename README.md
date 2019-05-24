# aws-eks-rds-terraform
![enter image description here](https://lh3.googleusercontent.com/MSDTbvsk5AS4BwkFsbJBsXwc_4YuoyCvzUeXvIRgWL-AmKKWF6cFmvlgwiR9a5TPMu0ixp7eSoR5EA)

# About...

This setup is used to install ***RDS*** and ***Amazon Elastic Container Service*** for Kubernetes (Amazon EKS) which is a managed service that makes it easy for you to run Kubernetes on AWS without needing to stand up or maintain your own Kubernetes control plane. Kubernetes is an open-source system for automating the deployment, scaling, and management of containerized applications.

# Table of Contents

* [Prerequisites](#prerequisites)
* [Create EKS cluster](#create_cluster)
* [Access EKS cluster](#eks)
* [Delete EKS cluster](#delete_cluster)




<a id="prerequisites"></a>
# Prerequisites
* `Install EKS Vagrant Box from (https://github.com/SubhakarKotta/aws-eks-vagrant-centos)`


<a id="create_cluster"></a>

# Create EKS Cluster

[Login to vagrant box](https://github.com/SubhakarKotta/aws-eks-vagrant-centos#access)


**Clone the below terraform repository**

* `$ git clone https://github.com/SubhakarKotta/aws-eks-rds-terraform.git`
* `$ cd aws-eks-rds-terraform/provisioning`


**Provide AWS Credentials**

* `$ aws configure`
* `............... AWS Access Key ID [None]:`
* `............... AWS Secret Access Key [None]:`
* `............... Default region name [None]:`
* `............... Default output format [None]:`
 
 
**Creating back-end storage for tfstate file in AWS S3**

1.  Create terraform state bucket:
```
$ aws s3 mb s3://<YOUR_BUCKET_NAME> --region <YOUR_REGION_NAME>
```
2.  Enable versioning on the newly created bucket:
```
$ aws s3api put-bucket-versioning --bucket <YOUR_BUCKET_NAME> --versioning-configuration Status=Enabled
```


 **Create EKS Cluster**
1.  Configure ***(terraform.tfvars)*** as per your requirements:


	```
	$ nano terraform.tfvars

	##########################################################################################
	# AWS Vars
	AWS_region                     = "us-west-2"
	AWS_vpc_name                   = "eks-terra-cloud"
	AWS_vpc_subnet                 = "172.16.0.0/16"
	AWS_azs                        = ["us-west-2a", "us-west-2b"]
	AWS_public_subnets             = ["172.16.0.0/20", "172.16.16.0/20"]
	AWS_tags                       = 
					 { 
					      "Environment"          = "Testing"
					 }
	EKS_name                       = "eks-terra-cloud"
	EKS_worker_groups              = [{ 
					       "instance_type"        = "m4.xlarge"
					       "asg_desired_capacity" = "5",
					       "asg_min_size"         = "5",
					       "asg_max_size"         = "7",
					       "key_name"             = "subhakarkotta"
					}]
	########################################################################################
	# AWS RDS Vars
	AWS_rds_name                   = "dev"
	AWS_rds_port                   = "5432"
	AWS_rds_identifier             = "eks-terra-cloud"
	AWS_rds_storage_type           = "gp2"
	AWS_rds_allocated_storage      = "20"
	AWS_rds_engine                 = "postgres"
	AWS_rds_engine_version         = "9.6.10"
	AWS_rds_instance_class         = "db.m4.xlarge"
	AWS_rds_username               = "postgres"
	AWS_rds_password               = "postgres123"
	AWS_rds_parameter_group_family = "postgres9.6"
      ```

2.  Initialize and pull terraform cloud specific dependencies:
```
$ terraform init
```
3. It's a good idea to sync terraform modules: 
```
$ terraform get -update
```
4. View terraform plan:
```
$ terraform plan
```
5. Apply terraform plan 
```
$ terraform apply
```


```
Terraform modules will create

-   VPC
-   Subnets
-   Routes
-   IAM Roles for master and nodes
-   Security Groups "Firewall" to allow master and nodes to communicate
-   EKS cluster
-   Autoscaling Group will create nodes to be added to the cluster
-   Security group for RDS
-   RDS with PostgreSQL

```


**Configure kubectl to allow us to connect to EKS cluster**
```
$ terraform output kubeconfig
```
**Add output of "terraform output kubeconfig" to ~/.kube/config**
```
$ terraform output kubeconfig > ~/.kube/config
```
**Verify kubectl connectivity**
```
$ kubectl get namespaces
$ kubectl get pods -o wide --all-namespaces
```

**Now you should be able to see nodes**
```
$ kubectl get nodes
```
**Install Tiller**
```
$ kubectl --namespace kube-system create serviceaccount tiller
$ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
$ helm init --service-account tiller --upgrade
```
[![asciicast](https://asciinema.org/a/248153.png)](https://asciinema.org/a/248153)

<a id="access_dashboard"></a>

# Access Kubernetes Dashboard

From ***local*** system execute the below commands
* `$ ssh -L 8001:localhost:8001 root@100.10.10.108` [***password : aws-eks***]

Use the below command to generate ***access token*** login to ***Dashboard***
* `$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`

Start proxy to access kubernetes dashboard
* `$ kubectl proxy`

***Click !***
[http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login)


<a id="delete_cluster"></a>

# Delete EKS Cluster

**### Destroy all terraform created infrastructure**
```
$ terraform destroy -auto-approve
```
