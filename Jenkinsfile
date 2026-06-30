pipeline {
    agent any
    stages {
        stage('Construccion') {
            steps {
                dir('app') {
                    sh 'pip3 install -r requirements.txt --break-system-packages'
                    sh 'python3 create_db.py'
                    echo 'Aplicacion construida correctamente'
                }
            }
        }
        stage('Pruebas') {
            steps {
                dir('app') {
                    sh 'python3 -c "import vulnerable_app"'
                    echo 'Verificando que la app no tenga errores de sintaxis'
                }
            }
        }
        stage('Despliegue') {
            steps {
                dir('app') {
                    sh 'docker build -t task-manager-app .'
                    sh 'docker rm -f task-manager-app-test || true'
                    sh 'docker run -d --name task-manager-app-test -p 5000:5000 task-manager-app'
                }
            }
        }
        stage('Analisis de Seguridad (OWASP ZAP)') {
            steps {
                script {
                    sh 'docker network create parcial3-net || true'
                    sh 'docker network connect parcial3-net task-manager-app-test || true'
                    sh 'mkdir -p zap-report'
                    sh '''
                        docker run --rm --network parcial3-net \
                        -v $WORKSPACE/zap-report:/zap/wrk/:rw \
                        zaproxy/zap-stable zap-baseline.py \
                        -t http://task-manager-app-test:5000 \
                        -r reporte_zap_jenkins.html || true
                    '''
                    echo 'Escaneo OWASP ZAP completado. Reporte generado en zap-report/reporte_zap_jenkins.html'
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'zap-report/*.html', allowEmptyArchive: true
        }
    }
}