pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: abhin785/jenkins-agent-with-docker:latest
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_AGENT_NAME)']
    env:
      - name: DOCKER_HOST
        value: tcp://localhost:2375
      - name: DOCKER_TLS_VERIFY
        value: "0"
    volumeMounts:
      - name: dockersock
        mountPath: /var/lib/docker
  - name: docker
    image: docker:20.10.16-dind
    securityContext:
      privileged: true
    volumeMounts:
      - name: dockersock
        mountPath: /var/lib/docker
  volumes:
  - name: dockersock
    emptyDir: {}
"""
        }
    }

    environment {
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
                container('docker') {
                    script {
                        docker.build(DOCKER_AGENT_IMAGE, '-f Dockerfile-agent .')
                    }
                }
            }
        }

        stage('Push Agent Image') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                            docker.image(DOCKER_AGENT_IMAGE).push()
                        }
                    }
                }
            }
        }

        stage('Build App Image') {
            steps {
                container('docker') {
                    script {
                        def buildDate = new Date().format('yyyyMMdd')
                        env.BUILD_DATE = buildDate
                        env.IMAGE_NAME = "${DOCKER_AGENT_IMAGE}:${buildDate}"
                        docker.build(env.IMAGE_NAME)
                    }
                }
            }
        }

        stage('Push App Image') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                            docker.image(env.IMAGE_NAME).push()
                        }
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
