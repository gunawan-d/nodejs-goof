pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerLogin')
    }
    stages {
        stage('Pull source code') {
            steps {
                echo 'Pull Code'
                git url: 'https://github.com/gunawan-d/nodejs-goof.git'
                sh 'npm install'
            }
        }
        stage('Build Docker Image and Push to Docker Registry') {
            steps {
                sh 'docker build -t gunawand/nodejsgoof:0.1 .'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push gunawand/nodejsgoof:0.1'
            }
        }
    }
}
