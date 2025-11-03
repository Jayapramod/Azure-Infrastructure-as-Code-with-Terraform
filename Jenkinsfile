pipeline {
    agent any
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    }

    environment {
        ARM_CLIENT_ID = credentials('azure-client-id')
        ARM_CLIENT_SECRET = credentials('azure-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID = credentials('azure-tenant-id')
        TF_WORKSPACE_DIR = "environments/${params.ENVIRONMENT}"
    }

    stages {
        stage('Generate SSH Key') {
            steps {
                sh '''
                    mkdir -p ${WORKSPACE}/ssh
                    # Remove any existing keys
                    rm -f ${WORKSPACE}/ssh/id_rsa*
                    # Generate new key with empty passphrase
                    ssh-keygen -t rsa -b 4096 -f ${WORKSPACE}/ssh/id_rsa -N '""'
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${env.TF_WORKSPACE_DIR}") {
                    sh """
                    terraform init \
                        -backend-config="resource_group_name=Jayrg" \
                        -backend-config="storage_account_name=jaystorageaccount05" \
                        -backend-config="container_name=tfstate" \
                        -backend-config="key=${params.ENVIRONMENT}.tfstate"
                    """
                }
            }
        }

        stage('Select Workspace') {
            steps {
                dir("${env.TF_WORKSPACE_DIR}") {
                    sh "terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}"
                }
            }
        }

        stage('Terraform Format') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh 'terraform fmt -recursive -check || true'
                    sh 'terraform fmt -recursive'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${env.TF_WORKING_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${env.TF_WORKSPACE_DIR}") {
                    sh """
                    terraform plan \
                        -var "project_name=jay-project-${params.ENVIRONMENT}" \
                        -var "location=eastasia" \
                        -var "public_subnet_prefix=10.0.1.0/24" \
                        -var "private_subnet_prefix=10.0.2.0/24" \
                        -var "vm_count=1" \
                        -var "vm_size=Standard_B1s" \
                        -var "admin_username=azureuser" \
                        -var "ssh_public_key_path=${WORKSPACE}/ssh/id_rsa.pub" \
                        -out=tfplan
                    """
                }
            }
        }

        stage('Approval') {
            when {
                expression { 
                    params.ACTION == 'apply' && !params.APPROVE_APPLY
                }
            }
            steps {
                script {
                    def plan = readFile "${env.TF_WORKING_DIR}/tfplan"
                    input message: "Review the plan output and approve to apply the changes:\n\n${plan}"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { 
                    params.ACTION == 'apply' && 
                    (params.APPROVE_APPLY || currentBuild.previousBuild?.result == 'SUCCESS')
                }
            }
            steps {
                dir("${env.TF_WORKING_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("${env.TF_WORKING_DIR}") {
                    input message: 'Are you sure you want to destroy the infrastructure?'
                    sh """
                    terraform destroy -auto-approve \
                        -var "project_name=jay-project-${params.ENVIRONMENT}" \
                        -var "location=eastasia" \
                        -var "ssh_public_key_path=${WORKSPACE}/ssh/id_rsa.pub"
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed for ${params.ENVIRONMENT} environment"
            // Don't clean workspace for local development
            // cleanWs()
        }
        success {
            echo "Successfully executed terraform ${params.ACTION}"
        }
        failure {
            echo "Failed to execute terraform ${params.ACTION}"
        }
    }
}