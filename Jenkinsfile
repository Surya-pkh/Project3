pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials')
        DOCKER_USERNAME = "${DOCKER_HUB_CREDS_USR}"
        DOCKER_PASSWORD = "${DOCKER_HUB_CREDS_PSW}"
    }
    
    triggers {
        // Poll GitHub every 2 minutes for changes (backup trigger)
        pollSCM('H/2 * * * *')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup SSH Key') {
            steps {
                script {
                    // Copy SSH key from Jenkins home to workspace
                    sh '''
                        if [ -f "/var/lib/jenkins/devops-key.pem" ]; then
                            cp /var/lib/jenkins/devops-key.pem ./devops-key.pem
                            chmod 600 ./devops-key.pem
                            echo "✅ SSH key copied to workspace"
                        else
                            echo "❌ SSH key not found at /var/lib/jenkins/devops-key.pem"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Determine Branch') {
            steps {
                script {
                    // Enhanced branch detection for better webhook support
                    def detectedBranch = env.BRANCH_NAME ?: env.GIT_BRANCH ?: sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    detectedBranch = detectedBranch?.replaceAll('origin/', '')
                    
                    echo "🌟 Detected branch: ${detectedBranch}"
                    echo "🌟 BRANCH_NAME env: ${env.BRANCH_NAME}"
                    echo "🌟 GIT_BRANCH env: ${env.GIT_BRANCH}"
                    echo "🌟 Build cause: ${currentBuild.getBuildCauses()}"

                    switch(detectedBranch) {
                        case 'dev':
                            env.DOCKER_REPO = 'suryapkh/project3-dev'
                            env.ENVIRONMENT = 'development'
                            break
                        case 'master':
                        case 'main':
                            env.DOCKER_REPO = 'suryapkh/project3-prod'
                            env.ENVIRONMENT = 'production'
                            break
                        default:
                            error "❌ Branch '${detectedBranch}' is not configured for deployment. Supported: dev, master, main"
                    }

                    echo "🐳 Selected Docker repository: ${env.DOCKER_REPO}"
                    echo "🏗️ Target environment: ${env.ENVIRONMENT}"
                }
            }
        }
        
        stage('Build and Push') {
            steps {
                script {
                    echo "Using build.sh script for automated build and push..."
                    sh 'chmod +x build.sh'
                    sh './build.sh'
                }
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                script {
                    // Only deploy for supported branches (dev and master/main)
                    if (env.GIT_BRANCH == 'dev' || env.GIT_BRANCH == 'origin/dev' || 
                        env.GIT_BRANCH == 'master' || env.GIT_BRANCH == 'origin/master' || 
                        env.GIT_BRANCH == 'main' || env.GIT_BRANCH == 'origin/main') {
                        echo "Deploying from branch: ${env.GIT_BRANCH} using deploy.sh"
                        sh 'chmod +x deploy.sh'
                        sh './deploy.sh'
                    } else {
                        echo "Skipping deployment for branch: ${env.GIT_BRANCH}"
                    }
                }
            }
        }
        
        stage('Clean Up') {
            steps {
                script {
                    // Clean up Docker images - get them from build.sh output or use pattern matching
                    sh '''
                        # Clean up any images from this build
                        docker images | grep "$(date +%Y%m%d)" | awk '{print $3}' | xargs -r docker rmi || true
                        # Clean up dangling images
                        docker image prune -f || true
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "🎉 SUCCESS: ${env.ENVIRONMENT} deployment completed successfully!"
            echo "🌐 Branch: ${env.BRANCH_NAME ?: env.GIT_BRANCH}"
            echo "🐳 Repository: ${env.DOCKER_REPO}"
        }
        failure {
            echo "💥 FAILED: ${env.ENVIRONMENT} deployment failed!"
            echo "🌐 Branch: ${env.BRANCH_NAME ?: env.GIT_BRANCH}"
            echo "🔍 Check logs for details"
        }
        always {
            echo "🏁 Pipeline finished for branch detection"
        }
    }
}