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
    }
}