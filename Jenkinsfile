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
            choices: ['preview' , 'apply' , 'show', 'preview-destroy' , 'destroy'],
            description: 'Terraform action to apply',
            name: 'action')
        choice(
            choices: ['master' , 'dev' , 'qa', 'staging'],
            description: 'Choose branch to build and deploy',
            name: 'branch')
        string(name: 'bucket', defaultValue : 'subhakar-state-bucket', description: "Bucket name to store .tfstate file")
        string(name: 'region', defaultValue : 'us-west-2', description: "Region name where the bucket resides")
        string(name: 'cluster', defaultValue : 'demo-cloud', description: "EKS Cluster name")
        text(name: 'parameters', defaultValue : 'Please check the input https://github.com/SubhakarKotta/aws-eks-rds-terraform/blob/master/provisioning/terraform.tfvars', description: "Parameters that are required by terraform to create cluster. File <cluster>-terraform.tfvars will be created and will be feeded as input to terraform through --var-file parameter")
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
                expression { params.action == 'preview' || params.action == 'apply' }
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") { 
                            writeFile file: "${cluster}-terraform.tfvars", text: "${parameters}"
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
                expression { params.action == 'preview' || params.action == 'apply' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                             sh '${TERRAFORM_HOME}/terraform plan -var EKS_name=${cluster} --var-file=${cluster}-terraform.tfvars'
                        }
                    }
                }
            }
        }
       
        stage('apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") {
                               sh '${TERRAFORM_HOME}/terraform plan -out=${cluster}-plan -var EKS_name=${cluster}  --var-file=${cluster}-terraform.tfvars'
                               sh '${TERRAFORM_HOME}/terraform apply -auto-approve ${cluster}-plan'
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'awsCredentials',accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
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