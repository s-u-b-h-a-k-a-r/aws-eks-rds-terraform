pipeline {
   agent { label 'master' }

   environment {
       TERRAFORM_HOME = tool name: 'terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
       KUBECTL_HOME = tool name: 'kubectl', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
       AWS_IAM_AUTHENTICATOR_HOME = tool name: 'aws-iam-authenticator', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
       HELM_HOME = tool name: 'helm', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
    }   
    options {
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        ansiColor('xterm')
    }
    parameters {       
        choice(
            choices: ['preview' , 'create' , 'show', 'preview-destroy' , 'destroy', 'remove-state'],
            description: '<H4>preview - to list the resources being created <br> create - creates a new cluster <br> show - list the resources of existing cluster <br> preview-destroy - list the resources of existing cluster that will be destroyed><br>destroy - destroys the cluster</H4>',
            name: 'action')
        choice(
            choices: ['master' , 'dev' , 'qa', 'staging'],
            description: '<H4>Choose branch to build and deploy</H4>',
            name: 'branch')
        string(name: 'credential', defaultValue : '', description: "<H4>Provide your  AWS Credential ID from Global credentials</H4>")
        string(name: 'bucket', defaultValue : 'subhakar-state-bucket', description: "<H4>Existing S3 bucket name to store .tfstate file.</H4>")
        string(name: 'region', defaultValue : 'us-west-2', description: "<H4>Region name where the bucket resides.</H4>")
        string(name: 'cluster', defaultValue : 'demo-cloud', description: "<H4>Unique EKS Cluster name [non existing cluster in case of new].</H4>")
        text(name: 'parameters', defaultValue : '', description: "<H4>Provide all the parameters by visiting the below github link <br>https://github.com/SubhakarKotta/aws-eks-rds-terraform/blob/master/provisioning/terraform.tfvars <br><br> Make sure you update the values as per your requirements <br><br> Provide unique values for the below parameters <br> AWS_vpc_name|AWS_rds_identifier by appending  (cluster name)<br> E.g. <br> cluster: {demo-cluster} <br> AWS_vpc_name: {demo-cluster-vpc} <br>AWS_rds_identifier : {demo-cluster} </H4>")
        string(name: 'state', defaultValue : '', description: "<H4>Provide the json path to remove state</H4>")
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
     
      stage('remove-state') {
            when {
                expression { params.action == 'remove-state' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") { 
                            sh ' terraform state rm ${state} '
                        }
                    }
                }
            }
        }


        stage('init') {
            when {
                expression { params.action == 'preview' || params.action == 'create' || params.action == 'preview-destroy' || params.action == 'destroy'  || params.action == 'show' }
            }
            steps {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: params.credential,accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                        dir ("provisioning") { 
                            echo " =========== ^^^^^^^^^^^^ Using AWS Credential : ${credential}"
                            sh 'helm init --client-only'
			                sh 'rm -rf .terraform'
                            sh '${TERRAFORM_HOME}/terraform version'
                            sh '${TERRAFORM_HOME}/terraform init -backend-config="bucket=${bucket}" -backend-config="key=${cluster}/terraform.tfstate" -backend-config="region=${region}"'
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
                               sh '${TERRAFORM_HOME}/terraform plan -var EKS_name=${cluster} -destroy'
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
                            sh '${TERRAFORM_HOME}/terraform destroy -var EKS_name=${cluster} -force'
                        }
                    }
                }
            }
        }
    }
}
