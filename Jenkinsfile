pipeline {
    agent any

    parameters {
        string(name: 'NAMESPACE', defaultValue: 'default', description: 'Kubernetes Namespace to deploy to')
    }

    environment {
        IMAGE_REPO = "your-docker-repo/your-image"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
            }
        }

        stage('Set Build Date') {
            steps {
                script {
                    // Set build date as env variable to use in next stages
                    env.BUILD_DATE = new Date().format('yyyyMMdd')
                    env.IMAGE_NAME = "${env.IMAGE_REPO}:${env.BUILD_DATE}"
                    echo "Build date set to ${env.BUILD_DATE}"
                    echo "Image name set to ${env.IMAGE_NAME}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(env.IMAGE_NAME)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-credentials-id') {
                        docker.image(env.IMAGE_NAME).push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl apply -n ${params.NAMESPACE} -f k8s/deployment.yaml
                    kubectl set image deployment/your-deployment your-container=${env.IMAGE_NAME} -n ${params.NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build or deployment failed.'
        }
    }
}
