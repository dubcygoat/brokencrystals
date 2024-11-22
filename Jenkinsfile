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
        DOCKER_CRED = credentials('docker')
        DOCKER_HUB = 'https://hub.docker.com/repository/docker/dubcygoat/brokencrystals'
        LOCATION1 = '/app/data'
        // SEMGREP_BASELINE_REF = ""
        SEMGREP_PATH = '/var/lib/jenkins/.local/lib/python3.10/site-packages/semgrep'
        PATH = "$PATH:/var/lib/jenkins/.local/bin"
        SEMGREP_APP_TOKEN = credentials('SEMGREP_APP_TOKEN')
        //SEMGREP_PR_ID = "${env.CHANGE_ID}"

      //  SEMGREP_TIMEOUT = "300"
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
        stage('Git Leaks Scan') {
            steps {
                script {
                    sh 'rm -rf gitleaks-report.json'
                    sh 'docker run --rm -v "${PWD}:${LOCATION1}" zricethezav/gitleaks:latest detect --source="${LOCATION1}" --report-format="json"  --report-path="${LOCATION1}/gitleaks-report.json" || true'
                }
            }
        }
         stage('Qodana') {
            steps {
                 script {
                    sh '''docker run --rm -v "${PWD}:/data/project" -e QODANA_TOKEN=${QODANA_TOKEN}  jetbrains/qodana-js:2024.2 "qodana scan --save-report qodana-report.html" || true'''
                 }
            }
        }
        stage('Semgrep-Scan') {
          steps {
            sh '''
             semgrep ci --json-output=$PWD/semgrep-report.json
             '''
          }
      }
       stage('SonarQube Analysis') {
     steps {
        script {
                withSonarQubeEnv('sonar-server') {
                     sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectName=brokencrystals -Dsonar.projectKey=brokencrystals"
                }
             } 
         }
        }
         stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Snyk Test') {
            steps {
              script {
                    // Install Snyk if not found, to avoid "command not found" errors
                    sh  'npm install -g snyk'

              }
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                     // Perform a test with a custom severity threshold, e.g., medium or higher
                    sh 'snyk test || true' // --severity-threshold=high 

                    // Monitor and send results to Snyk online dashboard
                    sh "snyk monitor --org='dubcygoat' --project-name='brokencrystals'"
                }
            }
        }
        stage('Docker Login, build and push'){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker'){
                    echo 'Login Completed'
                    sh "docker build . -t  dubcygoat/brokencrystals:v1"
                    //sh 'echo $DOCKER_CRED | sudo docker login -u $DOCKER_USER -p $DOCKER_PASS'                		
                    sh 'docker push dubcygoat/brokencrystals:v1'
                    echo 'Brokencrystals has been pushed to dockerhub access it on $DOCKER_HUB Congratulations!!!'
                }
            }
        }
    }
        stage('Container Scanning with Trivy') {
            steps {
                    sh 'trivy image -f json -o trivyartifact.json dubcygoat/brokencrystals:v1'
                    //sh 'trivy image --format template --template "@/var/lib/jenkins/workspace/html.tpl" -o trivyartifact.html dubcygoat/brokencrystals:v1'
                }
            }
        // stage('Deploy to container'){
        //     steps{ 
        //       // sh 'docker run -d --name brokencrystals --network="host" -p 8081:80 dubcygoat/brokencrystals:v1'
        //         // 'docker ps'
        //     }
        // }
    stage('OWASP ZAP Scan') {
            steps {
                script {
                    // Start OWASP ZAP Docker container for scanning
                        sh 'docker run --user root -v $(pwd):/zap/wrk/:rw --rm -t zaproxy/zap-stable zap-baseline.py -t http://$(ip -f inet -o addr show ens33 | awk \'{print $4}\' | cut -d \'/\' -f 1):3000 -J zap_report.json || true'

                }
            }
            post {
                always {
                    // Archive the ZAP report for later analysis
                    archiveArtifacts artifacts: 'zap_report.json', allowEmptyArchive: true
                     // Archive the Trivy report for later analysis
                    archiveArtifacts artifacts: 'trivyartifact.json', allowEmptyArchive: true
                     // Archive the Dependency report for later analysis
                    archiveArtifacts artifacts: 'dependency-check-report.xml', allowEmptyArchive: true
                     // Archive the Dependency report for later analysis
                    archiveArtifacts artifacts: 'semgrep-report.json', allowEmptyArchive: true
                      // Archive the Dependency report for later analysis
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                      // Archive the Dependency report for later analysis
                    archiveArtifacts artifacts: 'qodana-report.html', allowEmptyArchive: true
                    
                }
            }
        }
    stage('Upload to defectdojo'){
             steps{ 
             script {
                    // upload scripts
                         //sh 'pip3 install requests'
                        //sh 'pip3 install boto3'
                        sh 'pip3 install datetime'
                        sh 'python3 upload_report.py zap_report.json'
                        sh 'python3 upload_report.py trivyartifact.json'
                        sh 'python3 upload_report.py dependency-check-report.xml' 
                        sh 'python3 upload_report.py semgrep-report.json'
                        sh 'python3 upload_report.py gitleaks-report.json'


                }
         }
    }
}
}

