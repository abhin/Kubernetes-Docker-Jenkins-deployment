pipeline {
    agent any

    parameters {
        string(name: 'NAMESPACE', defaultValue: 'default', description: 'Kubernetes namespace to deploy to')
    }

    environment {
        DOCKER_REPO = 'abhin785/kubernetes-docker-jenkins-deployment'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/abhin/Kubernetes-Docker-Jenkins-deployment.git'
            }
        }

        stage('Set Build ID') {
            steps {
                script {
                    env.BUILD_DATE = new Date().format('yyyyMMdd')
                    env.IMAGE_TAG = "${env.BUILD_DATE}"
                    echo "Build date tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        echo 'Logged into Docker Hub'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${DOCKER_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "helm upgrade --install myapp ./helm-chart --namespace ${params.NAMESPACE} --set image.tag=${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo 'All images built, pushed, and app deployed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
