pipeline {
   agent { label 'master' }

   environment {
       TERRAFORM_HOME = tool name: 'terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
       KUBECTL_HOME = tool name: 'kubectl', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
    }   
    options {
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        ansiColor('xterm')
    }
    parameters {
        choice(
            choices: ['preview' , 'create' , 'show', 'preview-destroy' , 'destroy'],
            description: '1 #  preview - to list the resources being created  2 #  create - creates a new cluster   3 #  show - list the resources of existing cluster  4 #  preview-destroy - list the resources of existing cluster that will be destroyed   5 #  destroy - destroys the cluster',
            name: 'action')
        choice(
            choices: ['master' , 'dev' , 'qa', 'staging'],
            description: 'Choose branch to build and deploy',
            name: 'branch')
        string(name: 'credential', defaultValue : '', description: "Provide your AWS CredentialID from Global credentials")
        string(name: 'bucket', defaultValue : 'subhakar-state-bucket', description: "Existing bucket name to store .tfstate file. ")
        string(name: 'region', defaultValue : 'us-west-2', description: "Region name where the bucket resides.")
        string(name: 'cluster', defaultValue : 'demo-cloud', description: "EKS Cluster name [non existing cluster in case of new].")
        text(name: 'parameters', defaultValue : 'Please provide all the parameters by visiting the github link [https://github.com/SubhakarKotta/aws-eks-rds-terraform/blob/master/provisioning/terraform.tfvars]. Make sure you update the values as per your requirements also provide unique values for the parameters AWS_vpc_name|AWS_rds_identifier|', description: "")
    }
    
     stages {

         stage('Setup') {
             steps {
                script {
                    currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + "-eks-" + params.cluster
                }
            }
        }

        stage('Git Checkout'){
            steps {
		      git url: 'https://github.com/SubhakarKotta/aws-eks-rds-terraform',branch: "${branch}"
          }
	    }
        
        stage('Create terraform.tfvars') {
            when {
                expression { params.action == 'preview' || params.action == 'create' }
            }
            steps {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") { 
                            echo "${parameters}"
                            writeFile file: "${cluster}-terraform.tfvars", text: "${parameters}"
                            echo " =========== ^^^^^^^^^^^^ Created file ${cluster}-terraform.tfvars"
                        }
                    }
            }
        }
         
        stage('init') {
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") { 
                            echo " =========== ^^^^^^^^^^^^ Using AWS Credential : ${credential}"
                            sh '${TERRAFORM_HOME}/terraform version'
                            sh '${TERRAFORM_HOME}/terraform init -backend-config="bucket=${bucket}" -backend-config="key=${cluster}/terraform.tfstate" -backend-config="region=${region}"'
                            sh '${TERRAFORM_HOME}/terraform workspace new ${cluster} || true'
                            sh '${TERRAFORM_HOME}/terraform workspace select ${cluster}'
                        }
                    }
                }
            }
        }

        stage('validate') {
            when {
                expression { params.action == 'preview' || params.action == 'create' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") { 
                            sh '${TERRAFORM_HOME}/terraform validate -var EKS_name=${cluster} --var-file=${cluster}-terraform.tfvars'
                        }
                    }
                }
            }
        }
        stage('preview') {
            when {
                expression { params.action == 'preview' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                             sh '${TERRAFORM_HOME}/terraform plan -var EKS_name=${cluster} --var-file=${cluster}-terraform.tfvars'
                        }
                    }
                }
            }
        }
       
        stage('create') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                               sh '${TERRAFORM_HOME}/terraform plan -out=${cluster}-plan -var EKS_name=${cluster}  --var-file=${cluster}-terraform.tfvars'
                               sh '${TERRAFORM_HOME}/terraform apply -auto-approve ${cluster}-plan'
                        }
                    }
                }
            }
        }

         stage('dashboard') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                               sh '${TERRAFORM_HOME}/terraform output kubeconfig > ./${cluster}_kubeconfig'
                               sh 'export KUBECONFIG=./${cluster}_kubeconfig'
                               sh 'kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml --kubeconfig=./${cluster}_kubeconfig'
                               sh 'kubectl apply -f eks-admin-service-account.yaml --kubeconfig=./${cluster}_kubeconfig'
                        }
                    }
                }
            }
         }       

        stage('show') {
            when {
                expression { params.action == 'show' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                               sh '${TERRAFORM_HOME}/terraform show'
                        }
                    }
                }
            }
        }
        
        stage('preview-destroy') {
            when {
                expression { params.action == 'preview-destroy' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                               sh '${TERRAFORM_HOME}/terraform workspace select ${cluster}'
                               sh '${TERRAFORM_HOME}/terraform plan -destroy'
                        }
                    }
                }
            }
        }
       
        stage('destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                            sh '${TERRAFORM_HOME}/terraform workspace select ${cluster}'
                            sh '${TERRAFORM_HOME}/terraform destroy -force'
                        }
                    }
                }
            }
        }
    }
}