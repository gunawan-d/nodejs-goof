pipeline {
    agent none
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerLogin')
        // SNYK_CREDENTIALS = credentials('SnykToken')
        // SONARQUBE_CREDENTIALS = credentials('SonarToken')
    }
    stages {
        stage('Build dockerfile') {
            agent {
                docker {
                    image 'node:lts-buster-slim'
                }
            }
            steps {
                sh 'npm install'
            }
        }
        stage('Push to Docker Registry Docker Hub') {
            agent {
                docker {
                    image 'docker:stable'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            environment {
                DOCKER_REGISTRY = 'hub.docker.com'
                DOCKER_IMAGE = '${{ github.repository }}'
                DOCKER_TAG = 'latest'
                REGISTRY_CREDENTIALS_ID = 'DockerLogin'
            }
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${REGISTRY_CREDENTIALS_ID}") {
                        sh 'docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG} .'
                        sh 'docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}'
                    }
                }
            }

        }
    }
}
