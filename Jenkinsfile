pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "devopstejas/website"
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
    }

    triggers {
        cron('0 0 25 * *')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Teju-hub/website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh "echo ${DOCKER_CREDENTIALS_PSW} | docker login -u ${DOCKER_CREDENTIALS_USR} --password-stdin"
                sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sshagent(['k8s-master-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@54.242.124.196 '
                            kubectl apply -f ~/kubernetes/deployment.yaml
                            kubectl apply -f ~/kubernetes/service.yaml
                            kubectl rollout status deployment/website-deployment
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}