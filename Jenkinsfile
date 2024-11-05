pipeline {
    tools {
        jdk 'jdk21'
        nodejs 'node23'
        snyk 'snyk@latest'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        QODANA_TOKEN = credentials('qodana-token')
        QODANA_ENDPOINT = 'https://qodana.cloud'
        SNYK_HOME = 'snyk@latest'
    }
    agent any
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Git Checkout') {
            steps {
                script {
                    git branch: 'stable',
                        credentialsId: 'git-scm',
                        url: 'https://github.com/dubcygoat/brokencrystals.git'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectName=brokencrystals -Dsonar.projectKey=brokencrystals"
                }
            }
        }
        stage('Snyk Test') {
            steps {
                script {
                    // Install Snyk if not found, to avoid "command not found" errors
                    sh 'npm install -g snyk'
                }
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                     // Perform a test with a custom severity threshold, e.g., medium or higher
                    sh 'snyk test || true' // --severity-threshold=high 

                    // Monitor and send results to Snyk online dashboard
                    sh "snyk monitor --org='dubcygoat' --project-name='brokencrystals'"
                }
            }
        }
    }
}







// pipeline {
//     environment {
//         QODANA_TOKEN=credentials('qodana-token')
//         QODANA_ENDPOINT='https://qodana.cloud'
//     }
//     agent {
//         docker {
//             args '''
//               -v "${WORKSPACE}":/data/project
//               --entrypoint=""
//               '''
//             image 'jetbrains/qodana-js:2024.1'
//         }
//     }
//     stages {
//         stage('Qodana') {
//             steps {
//                 sh '''qodana'''
//             }
//         }
//     }
// }

