pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerLogin')
    }
    stages {
        stage('Build Docker') {
            agent {
                dockerContainer {
                    image 'node:lts-buster-slim'
                }
            }
            steps {
                sh 'npm install'
            }
        }
        stage('Build Docker Image and Push to Docker Registry') {
            agent {
                dockerContainer {
                    image 'docker:dind'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            environment {
                DOCKER_REGISTRY = 'hub.docker.com'
                DOCKER_IMAGE = 'gunawan-d/nodejs-goof' // Ganti dengan nama repository Docker kamu
                DOCKER_TAG = 'latest'
                REGISTRY_CREDENTIALS_ID = 'DockerLogin'
            }
            steps {
                sh 'docker build -t gunawand/nodejsgoof:0.1 .'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push gunawand/nodejsgoof:0.1'
            }
        }
    }
    triggers {
        githubPush()
    }
}
