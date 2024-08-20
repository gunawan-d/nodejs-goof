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
        // // // stage('SCA Snyk Test') {
        // // //     agent {
        // // //         docker {
        // // //             image 'snyk/snyk:node'
        // // //             args '-u root --network host --env SNYK_TOKEN=$SNYK_CREDENTIALS_PSW --entrypoint='
        // // //         }
        // // //     }
        // // //     steps {
        // // //         catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        // // //             sh 'snyk test --json > snyk-scan-report.json'
        // // //         }
        // // //         sh 'cat snyk-scan-report.json'
        // // //         archiveArtifacts artifacts: 'snyk-scan-report.json'
        // // //     }
        // // // }
        // // // stage('Build NPM') {
        // // //     agent {
        // // //         docker {
        // // //             image 'node:lts-buster-slim' // Use Node.js Docker image
        // // //             args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        // // //         }
        // // //     }
        // // //     steps {
        // // //         sh 'npm install'
        // // //     }
        // // // }
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
        stage('Build Docker Image') {
            agent {
                docker {
                    image 'docker:dind'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh 'docker build -t gunawand/nodejsgoof:0.1 .'
            }
        }
        stage('Push Docker Image To CR') {
            agent {
                docker {
                    image 'docker:dind'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push gunawand/nodejsgoof:0.1'
            }
        }
        // stage('Deploy Docker Image') {
        //     agent {
        //         docker {
        //             image 'kroniak/ssh-client'
        //             args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        //         }
        //     }
        //     steps {
        //         withCredentials([sshUserPrivateKey(credentialsId: "DeploymentSSHKey", keyFileVariable: 'keyfile')]) {
        //             sh 'ssh -i ${keyfile} -o StrictHostKeyChecking=no -p 8022 devops@147.139.166.250 "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"'
        //             sh 'ssh -i ${keyfile} -o StrictHostKeyChecking=no -p 8022 devops@147.139.166.250 docker pull gunawand/nodejsgoof:0.1'
        //             sh 'ssh -i ${keyfile} -o StrictHostKeyChecking=no -p 8022 devops@147.139.166.250 docker rm --force mongodb'
        //             sh 'ssh -i ${keyfile} -o StrictHostKeyChecking=no -p 8022 devops@147.139.166.250 docker run --detach --name mongodb -p 27017:27017 mongo:3'
        //             sh 'ssh -i ${keyfile} -o StrictHostKeyChecking=no -p 8022 devops@147.139.166.250 docker rm --force nodejsgoof'
        //             sh 'ssh -i ${keyfile} -o StrictHostKeyChecking=no -p 8022 devops@147.139.166.250 docker run -it --detach --name nodejsgoof --network host gunawand/nodejsgoof:0.1'
        //         }
        //     }
        // }
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
        // stage('DAST Nuclei') {
        //     agent {
        //         docker {
        //             image 'projectdiscovery/nuclei'
        //             args '--user root --network host --entrypoint='
        //         }
        //     }
        //     steps {
        //         catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        //             sh 'nuclei -u http://147.139.166.250:3001 -nc -j > nuclei-report.json'
        //             sh 'cat nuclei-report.json'
        //         }
        //         archiveArtifacts artifacts: 'nuclei-report.json'
        //     }
        // }
    }
}
