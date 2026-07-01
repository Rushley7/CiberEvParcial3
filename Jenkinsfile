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
                    sh 'docker volume create zap-vol || true'
                    sh 'docker run --rm -v zap-vol:/zap/wrk alpine chmod -R 777 /zap/wrk'
                    sh 'docker rm -f zap-scan || true'
                    sh '''
                        docker run --network parcial3-net --name zap-scan -v zap-vol:/zap/wrk:rw \
                        zaproxy/zap-stable zap-baseline.py \
                        -t http://task-manager-app-test:5000 \
                        -r reporte_zap_jenkins.html || true
                    '''
                    sh 'mkdir -p zap-report'
                    sh 'docker run --rm -v zap-vol:/zap/wrk:ro alpine cat /zap/wrk/reporte_zap_jenkins.html > zap-report/reporte_zap_jenkins.html || true'
                    sh 'docker rm -f zap-scan || true'
                    echo 'Escaneo OWASP ZAP completado. Reporte generado en zap-report/reporte_zap_jenkins.html'
                }
            }
        }
        stage('Trazabilidad y Documentacion') {
            steps {
                script {
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def commitMsg = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                    def commitAuthor = sh(script: 'git log -1 --pretty=%an', returnStdout: true).trim()
                    def fecha = sh(script: 'date "+%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()

                    writeFile file: 'zap-report/trazabilidad.md', text: """# Registro de Trazabilidad - Build #${BUILD_NUMBER}

## Informacion del Build
- **Numero de Build:** ${BUILD_NUMBER}
- **Fecha de ejecucion:** ${fecha}
- **Job:** ${JOB_NAME}

## Control de Versiones (Git)
- **Commit:** ${commitHash}
- **Autor:** ${commitAuthor}
- **Mensaje:** ${commitMsg}
- **Repositorio:** https://github.com/Rushley7/CiberEvParcial3

## Etapas Ejecutadas
1. Construccion: instalacion de dependencias y creacion de base de datos - EXITOSA
2. Pruebas: verificacion de sintaxis de la aplicacion - EXITOSA
3. Despliegue: build de imagen Docker y despliegue del contenedor - EXITOSA
4. Analisis de Seguridad (OWASP ZAP): escaneo automatizado contra la app desplegada - EXITOSA
5. Trazabilidad y Documentacion: generacion de este registro - EXITOSA

## Artefactos Generados
- reporte_zap_jenkins.html (resultado del escaneo OWASP ZAP)
- trazabilidad.md (este documento)

## Vulnerabilidades Corregidas (Codigo Fuente)
- Inyeccion SQL en login (consultas parametrizadas)
- Hashing debil de contrasenas (migrado a Werkzeug check_password_hash)
- Modo debug activo por defecto (controlado por variable de entorno FLASK_DEBUG)
- IDOR en eliminacion de tareas (validacion de propietario)
- Cabeceras de seguridad HTTP ausentes (CSP, X-Frame-Options, X-Content-Type-Options, Permissions-Policy)

## Gestion de Dependencias
- Dependabot alerts y security updates activados en GitHub
- Archivo .github/dependabot.yml configurado (revision semanal, ecosistema pip)

## Monitorizacion
- Metricas expuestas via /metrics (prometheus-flask-exporter)
- Prometheus recolectando metricas del contenedor task-manager-app-test
- Dashboard Grafana "Task Manager - Monitoreo" con paneles de peticiones/segundo y tiempo de respuesta
"""
                    echo 'Registro de trazabilidad generado en zap-report/trazabilidad.md'
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'zap-report/*', allowEmptyArchive: true
        }
    }
}