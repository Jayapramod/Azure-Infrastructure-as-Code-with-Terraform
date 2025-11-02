pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select the environment to deploy'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the action to perform'
        )
        booleanParam(
            name: 'APPROVE_APPLY',
            defaultValue: false,
            description: 'Check to approve infrastructure changes'
        )
    }

    environment {
        // Local workspace directory - this will be your repository root
        TF_WORKING_DIR = "environments/${params.ENVIRONMENT}"
        // If you need Azure credentials later, uncomment these:
        /*
        ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        ARM_CLIENT_ID = credentials('AZURE_CLIENT_ID')
        ARM_CLIENT_SECRET = credentials('AZURE_CLIENT_SECRET')
        ARM_TENANT_ID = credentials('AZURE_TENANT_ID')
        */
    }

    stages {
        stage('Workspace Info') {
            steps {
                echo "Working directory: ${env.WORKSPACE}"
                echo "Environment: ${params.ENVIRONMENT}"
                echo "Action: ${params.ACTION}"
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${env.TF_WORKING_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Format') {
            steps {
                dir("${env.TF_WORKING_DIR}") {
                    sh 'terraform fmt -check'
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
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                dir("${env.TF_WORKING_DIR}") {
                    sh """
                    terraform plan \
                        -var "project_name=jay-project-${params.ENVIRONMENT}" \
                        -var "location=eastasia" \
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
                        -var "location=eastasia"
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