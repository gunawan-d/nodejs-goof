pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerLogin')
    }
    stages {
        stage('Pull Source Code') {
            steps {
                sh 'git clone https://github.com/gunawan-d/nodejs-goof.git'
                dir('nodejs-goof') {
                    sh 'npm install'
                }
            }
        }
        stage('Build Docker Image and Push to Docker Registry') {
            agent {
                docker {
                    image 'docker:dind'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                dir('nodejs-goof') {
                    sh 'docker build -t gunawand/nodejsgoof:0.1 .'
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh 'docker push gunawand/nodejsgoof:0.1'
                }
            }
        }
    }
}
