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
    image: subhakarkotta/terraform-kubectl-helm-awscli:0.12.2-v1.12.7-v2.13.1-1.16.179
    command: ['cat']
    tty: true
"""
    }
  }
    options {
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
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
        string(name: 'dockercredential', defaultValue : '<YOUR_DOCKER_CREDENTIAL>', description: "Provide your  Docker Credential ID from Global credentials")   
        string(name: 'awscredential', defaultValue : '<YOUR_AWS_CREDENTIAL>', description: "Provide your  AWS Credential ID from Global credentials")
        string(name: 'bucket', defaultValue : '<YOUR_BUCKET_NAME>', description: "Existing S3 bucket name to store <.tfstate> file.")
        string(name: 'region', defaultValue : '<YOUR_REGION>', description: "Region name where the bucket resides.")
        string(name: 'cluster', defaultValue : '<YOUR_CLUSTER>', description: "Unique EKS Cluster name [non existing cluster in case of new].")
        string(name: 'state', defaultValue : '<YOUR_JSON_PATH>', description: "Provide the json path to remove state")
        text(name: 'parameters', defaultValue : '<YOUR_TERRAFORM_TFVARS>', description: "Provide all the parameters by visiting the below github link https://github.com/SubhakarKotta/aws-eks-rds-terraform/provisioning/terraform.tfvars.template  Make sure you update the values as per your requirements.  Provide unique values for the parameters  AWS_vpc_name|AWS_rds_identifier by appending  (cluster name) E.g.  cluster: {subhakar-demo-cluster}  AWS_vpc_name: {subhakar-demo-cluster-vpc} AWS_rds_identifier : {subhakar-demo-cluster} ")
        text(name: 'pega', defaultValue : '', description: "")
    }

    environment {
       PLAN_NAME= "${cluster}-eks-terraform-plan"
       TFVARS_FILE_NAME= "${cluster}-eks-terraform.tfvars"
       PEGA_VALUES_YAML_TEMPLATE= "pega/templates/eks_values.tpl"
       GIT_REPO = "https://github.com/SubhakarKotta/aws-eks-rds-terraform.git"
    }   
    
    stages {
        stage('Set Build Display Name') {
            steps {
                script {
                    currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + "-eks-" + params.cluster
                    currentBuild.description = "Preview/Create/Validate/Destroy EKS Cluster and Postgres database"
                }
            }
        }
        stage('Git Checkout'){
            steps {
		             git url: "${GIT_REPO}",branch: "${branch}",credentialsId: 'github_kotts1'
            }
  	    }
        stage('Create eks_values.tpl') {
            when {
                expression { params.pega != '' && params.pega != null }
            }
            steps {
              container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                         dir ("provisioning") { 
                             echo "${pega}"
                             sh 'rm -f ${PEGA_VALUES_YAML_TEMPLATE}'
                             writeFile file: "${PEGA_VALUES_YAML_TEMPLATE}", text: "${pega}"
                         }
                     }
                 }
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
                   withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                       wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                            dir ("provisioning") { 
                                sh 'terraform init -backend-config="bucket=${bucket}" -backend-config="key=${cluster}/terraform.tfstate" -backend-config="region=${region}"'
                                sh 'terraform output kubeconfig > ./kubeconfig_${cluster} || true'
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
                   withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
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
                expression { params.action == 'preview' || params.action == 'create'  || params.action == 'destroy' }
             }
             steps {
                container('jenkins-slave-terraform-kubectl-helm-awscli'){ 
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                             dir ("provisioning") { 
                                 sh 'terraform validate -var  name=${cluster} --var-file=${TFVARS_FILE_NAME}'
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
                   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: params.dockercredential, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                           wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                               dir ("provisioning") {
                                  sh 'echo AWS_ACCESS_KEY_ID # ${AWS_ACCESS_KEY_ID}' 
                                  sh 'echo AWS_SECRET_ACCESS_KEY # ${AWS_SECRET_ACCESS_KEY}' 
                                  sh 'echo DOCKER_USERNAME # ${USERNAME}' 
                                  sh 'echo DOCKER_PASSWORD # ${PASSWORD}' 
                                  sh 'terraform plan  -var docker_username=$USERNAME -var docker_password=$PASSWORD -var aws_access_key_id=$AWS_ACCESS_KEY_ID  -var aws_secret_access_key=$AWS_SECRET_ACCESS_KEY -var name=$cluster --var-file=${TFVARS_FILE_NAME}  -out=${PLAN_NAME}'
                                 }
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
                     withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: params.dockercredential, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                         withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                             wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                                dir ("provisioning") {
                                    sh 'terraform plan     -var docker_username=$USERNAME -var docker_password=$PASSWORD -var aws_access_key_id=$AWS_ACCESS_KEY_ID  -var aws_secret_access_key=$AWS_SECRET_ACCESS_KEY -var name=$cluster --var-file=${TFVARS_FILE_NAME}  -out=${PLAN_NAME}'
                                    sh 'terraform apply   -var docker_username=$USERNAME -var docker_password=$PASSWORD aws_access_key_id=$AWS_ACCESS_KEY_ID  -var aws_secret_access_key=$AWS_SECRET_ACCESS_KEY -var name=$cluster --var-file=${TFVARS_FILE_NAME} -auto-approve'
                                 }
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
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
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
                       withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                           wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                               dir ("provisioning") {
                                 sh 'terraform plan -destroy -var name=${cluster} --var-file=${TFVARS_FILE_NAME}'
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
                     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.awscredential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                         wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                              dir ("provisioning") {
                                   sh 'terraform destroy -var name=${cluster} --var-file=${TFVARS_FILE_NAME} -force'
                               }
                         }
                     }
                } 
             }
         }
    }
}