pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('DockerLogin')
        SNYK_TOKEN = credentials('snyk-api-token')
        SONARQUBE_CREDENTIALS_PSW = credentials('SONARQUBE_CREDENTIALS_PSW')
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
        // stage('SCA Snyk Test') {
        //     agent {
        //         docker {
        //             image 'snyk/snyk:node'
        //             args '-u root --network host --env SNYK_TOKEN=$SNYK_CREDENTIALS_PSW --entrypoint='
        //         }
        //     }
        //     steps {
        //         catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        //             sh 'snyk test --json > snyk-scan-report.json'
        //         }
        //         sh 'cat snyk-scan-report.json'
        //         archiveArtifacts artifacts: 'snyk-scan-report.json'
        //     }
        // }
        // stage('Build NPM') {
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
        // stage('SAST Snyk') {
        //     agent {
        //       docker {
        //           image 'snyk/snyk:node'
        //           args '-u root --network host --env SNYK_TOKEN=$SNYK_CREDENTIALS_PSW --entrypoint='
        //       }
        //     }
        //     steps {
        //         withCredentials([string(credentialsId: 'snyk-api-token', variable: 'SNYK_TOKEN')]) {
        //             catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        //                 sh 'snyk auth $SNYK_TOKEN'
        //                 sh 'snyk code test --json > snyk-sast-report.json'
        //             }
        //             sh 'cat snyk-sast-report.json'
        //             archiveArtifacts artifacts: 'snyk-sast-report.json'
        //         }
        //     }
        // }
        stage('SAST SonarQube') {
            agent {
              docker {
                  image 'sonarsource/sonar-scanner-cli:latest'
                  args '--network host -v ".:/usr/src" --entrypoint='
              }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'sonar-scanner -Dsonar.projectKey=nodejs-goof -Dsonar.qualitygate.wait=true -Dsonar.sources=. -Dsonar.host.url=http://147.139.166.250:9009 -Dsonar.token=$SONARQUBE_CREDENTIALS_PSW' 
                }
            }
        }
        stage('Build & Push Docker image') {
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
        stage('Deploy Docker') {
            agent {
                docker {
                    image 'kroniak/ssh-client'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'DeploymentSSHUserPass', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
                    sh '''
                    sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no -p 8022 $SSH_USER@147.139.166.250 docker pull gunawand/nodejsgoof:0.1
                    sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no -p 8022 $SSH_USER@147.139.166.250 docker rm --force mongodb
                    sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no -p 8022 $SSH_USER@147.139.166.250 docker run --detach --name mongodb -p 27017:27017 mongo:3
                    sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no -p 8022 $SSH_USER@147.139.166.250 docker rm --force nodejsgoof
                    sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no -p 8022 $SSH_USER@147.139.166.250 docker run -it --detach --name nodejsgoof --network host gunawand/nodejsgoof:0.1
                    '''
                }
            }
        }
        stage('DAST OWASP ZAP') {
            agent {
                docker {
                    image 'ghcr.io/zaproxy/zaproxy:stable'
                    args '-u root --network host -v /var/run/docker.sock:/var/run/docker.sock --entrypoint= -v .:/zap/wrk/:rw'
                }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'zap-baseline.py -t http://147.139.166.250:3001 -r zapbaseline.html -x zapbaseline.xml'
                }
                sh 'cp /zap/wrk/zapbaseline.html ./zapbaseline.html'
                sh 'cp /zap/wrk/zapbaseline.xml ./zapbaseline.xml'
                archiveArtifacts artifacts: 'zapbaseline.html'
                archiveArtifacts artifacts: 'zapbaseline.xml'
            }
        }
    }
}
