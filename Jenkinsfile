pipeline {
    agent any

    environment {
        DOCKER_AGENT_IMAGE = "your-dockerhub-user/jenkins-agent-with-docker:latest"
        DOCKER_AGENT_IMAGE = "abhin785/kubernetes-docker-jenkins-deployment"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/abhin/Kubernetes-Docker-Jenkins-deployment.git', branch: 'master'
            }
        }

        stage('Build Agent Image') {
            steps {
                script {
                    docker.build(DOCKER_AGENT_IMAGE, '-f Dockerfile-agent .')
                }
            }
        }

        stage('Push Agent Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                        docker.image(DOCKER_AGENT_IMAGE).push()
                    }
                }
            }
        }

        stage('Build App Image') {
            steps {
                script {
                    def buildDate = new Date().format('yyyyMMdd')
                    env.BUILD_DATE = buildDate
                    env.IMAGE_NAME = "${DOCKER_AGENT_IMAGE}:${buildDate}"
                    docker.build(env.IMAGE_NAME)
                }
            }
        }

        stage('Push App Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                        docker.image(env.IMAGE_NAME).push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl apply -f deployment.yaml
                    kubectl set image deployment/kubernetes-jenkins-deployment kubernetes-jenkins-container=${env.IMAGE_NAME} -n default
                    """
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
