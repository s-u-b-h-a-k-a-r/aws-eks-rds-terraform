pipeline {
  agent {
    kubernetes {
      //cloud 'kubernetes'
      label 'jenkins-slave-terraform-kubectl-helm-awscli'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jenkins-slave-terraform-kubectl-helm-awscli
    image: subhakarkotta/terraform-kubectl-helm-awscli
    command: ['cat']
    tty: true
"""
    }
  }
    options {
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        ansiColor('xterm')
    }
    parameters {
        choice(
            choices: ['preview' , 'create' , 'show', 'preview-destroy' , 'destroy' , 'remove-state'],
            description: 'preview - to list the resources being created.  create - creates a new cluster.  show - list the resources of existing cluster.  preview-destroy - list the resources of existing cluster that will be destroyed. destroy - destroys the cluster',
            name: 'action')
        choice(
            choices: ['master' , 'dev' , 'qa', 'staging'],
            description: 'Choose branch to build and deploy',
            name: 'branch')
        string(name: 'credential', defaultValue : '<YOUR_CREDENTIAL>', description: "Provide your  AWS Credential ID from Global credentials")
        string(name: 'bucket', defaultValue : '<YOUR_BUCKET_NAME>', description: "Existing S3 bucket name to store <.tfstate> file.")
        string(name: 'region', defaultValue : '<YOUR_REGION>', description: "Region name where the bucket resides.")
        string(name: 'cluster', defaultValue : '<YOUR_CLUSTER>', description: "Unique EKS Cluster name [non existing cluster in case of new].")
        text(name: 'parameters', defaultValue : '<YOUR_TERRAFORM_TFVARS>', description: "Provide all the parameters by visiting the below github link https://github.com/SubhakarKotta/aws-eks-rds-terraform/provisioning/terraform.tfvars.template  Make sure you update the values as per your requirements.  Provide unique values for the parameters  AWS_vpc_name|AWS_rds_identifier by appending  (cluster name) E.g.  cluster: {subhakar-demo-cluster}  AWS_vpc_name: {subhakar-demo-cluster-vpc} AWS_rds_identifier : {subhakar-demo-cluster} ")
        string(name: 'state', defaultValue : '<YOUR_JSON_PATH>', description: "Provide the json path to remove state")
    }

    environment {
       PLAN_NAME= "${cluster}-eks-terraform-plan"
       TFVARS_FILE_NAME= "${cluster}-eks-terraform.tfvars"
       GIT_REPO = "https://github.com/SubhakarKotta/aws-eks-rds-terraform.git"
    }   
    
    stages {
        stage('Set Build Display Name') {
            steps {
                script {
                    currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + "-eks-" + params.cluster
                    currentBuild.description = "Creates EKS Cluster and Postgres database"
                }
            }
        }
        stage('Git Checkout'){
            steps {
		             git url: "${GIT_REPO}",branch: "${branch}"
            }
  	    }
        stage('Create terraform.tfvars') {
            steps {
              container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                         dir ("provisioning") { 
                             echo "${parameters}"
                             writeFile file: "${TFVARS_FILE_NAME}", text: "${parameters}"
                             echo " ############ Cluster @@@@@ ${cluster} @@@@@ #############"
                             echo " ############ Using @@@@@ ${TFVARS_FILE_NAME} @@@@@ #############"
                         }
                     }
               }
             }
         } 
        stage('versions') {
            steps {
                container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                      wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            sh 'terraform version'
                            sh 'kubectl version'
                            sh 'helm version --client'
                            sh 'aws --version'
                       }
                 }
             }
         }
        stage('init') {
            steps {
               container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                   withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                       wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            dir ("provisioning") { 
                                sh 'terraform init -backend-config="bucket=${bucket}" -backend-config="key=${cluster}/terraform.tfstate" -backend-config="region=${region}"'
                            }
                         }
                     }
                 }
             }
         }
        stage('remove-state') {
            when {
                expression { params.action == 'remove-state' }
            }
            steps {
               container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                   withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                       wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            dir ("provisioning") { 
                               sh 'terraform state rm ${state}'
                            }
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
                container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                             dir ("provisioning") { 
                                 sh 'terraform validate -var  EKS_name=${cluster} --var-file=${TFVARS_FILE_NAME}'
                             }
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
               container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            dir ("provisioning") {
                                sh 'terraform plan -var EKS_name=$cluster --var-file=${TFVARS_FILE_NAME}'
                             }
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
                container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                              dir ("provisioning") {
                                 sh 'terraform plan  -var EKS_name=$cluster --var-file=${TFVARS_FILE_NAME}  -out=${PLAN_NAME}'
                                 sh 'terraform apply  -auto-approve ${PLAN_NAME}'
                                }
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
                container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                             dir ("provisioning") {
                                sh 'terraform show'
                             }
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
                  container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                           wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                               dir ("provisioning") {
                                 sh 'terraform plan -destroy -var EKS_name=${cluster} --var-file=${TFVARS_FILE_NAME}'
                               }
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
                container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                              dir ("provisioning") {
                                   sh 'terraform destroy -var EKS_name=${cluster} --var-file=${TFVARS_FILE_NAME} -force'
                               }
                         }
                     }
                } 
             }
         }
    }
}