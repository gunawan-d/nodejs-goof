pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerLogin')
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Secret Scanning Using Trufflehog'){
            agent {
                docker {
                    image 'trufflesecurity/trufflehog:latest'
                    args '--entrypoint='
                }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'trufflehog filesystem . --exclude-paths trufflehog-excluded-paths.txt --fail --json --no-update > trufflehog-scan-result.json'
                }
                // sh 'trufflehog filesystem . --exclude-paths trufflehog-excluded-paths.txt --fail --json --no-update > trufflehog-scan-result.json'
                sh 'cat trufflehog-scan-result.json'
                archiveArtifacts artifacts: 'trufflehog-scan-result.json'
            }
    	}
        stage('SCA Trivy Scan Dockerfile') {
            agent {
              docker {
                  image 'aquasec/trivy:latest'
                  args '-u root --network host --entrypoint='
              }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'trivy config Dockerfile --exit-code=1 --format json > trivy-scan-dockerfile-report.json'
                }
                sh 'cat trivy-scan-dockerfile-report.json'
                archiveArtifacts artifacts: 'trivy-scan-dockerfile-report.json'
            }
        }
        stage('Build NPM') {
        //     agent {
        //         docker {
        //             image 'node:lts-buster-slim' // Use Node.js Docker image
        //             args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        //         }
        //     }
        //     steps {
        //         sh 'npm install'
        //     }
        // }
        stage('Build Docker Image and Push to Docker Registry') {
            agent {
                docker {
                    image 'docker:dind'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh 'docker build -t gunawand/nodejsgoof:0.1 .'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push gunawand/nodejsgoof:0.1'
            }
        }
    }
}
