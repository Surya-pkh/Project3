pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Determine Branch') {
            steps {
                script {
                    env.GIT_BRANCH = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    echo "Current branch: ${env.GIT_BRANCH}"

                    if (env.GIT_BRANCH == 'dev' || env.GIT_BRANCH == 'origin/dev') {
                        env.DOCKER_REPO = 'suryapkh/project3-dev'
                    } else if (env.GIT_BRANCH == 'master' || env.GIT_BRANCH == 'origin/master' || env.GIT_BRANCH == 'main' || env.GIT_BRANCH == 'origin/main') {
                        env.DOCKER_REPO = 'suryapkh/project3-prod'
                    } else {
                        error "Branch ${env.GIT_BRANCH} is not supported for deployment"
                    }

                    echo "Selected Docker repository: ${env.DOCKER_REPO}"
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    env.BUILD_TAG = sh(script: 'date +%Y%m%d-%H%M%S', returnStdout: true).trim()
                    sh "docker build -t ${env.DOCKER_REPO}:${env.BUILD_TAG} ."
                    sh "docker tag ${env.DOCKER_REPO}:${env.BUILD_TAG} ${env.DOCKER_REPO}:latest"
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh 'echo $DOCKER_HUB_CREDS_PSW | docker login -u $DOCKER_HUB_CREDS_USR --password-stdin'
                    sh "docker push ${env.DOCKER_REPO}:${env.BUILD_TAG}"
                    sh "docker push ${env.DOCKER_REPO}:latest"
                }
            }
        }
        
        stage('Deploy') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'origin/dev'
                    branch 'master'
                    branch 'origin/master'
                }
            }
            steps {
                script {
                    sh './deploy.sh'
                }
            }
        }
        
        stage('Clean Up') {
            steps {
                sh "docker rmi ${env.DOCKER_REPO}:${env.BUILD_TAG}"
                sh "docker rmi ${env.DOCKER_REPO}:latest"
                sh 'docker image prune -f'
            }
        }
    }
    
    post {
        success {
            echo 'Build, push, and deploy completed successfully!'
        }
        failure {
            echo 'Build, push, or deploy failed!'
        }
    }
}