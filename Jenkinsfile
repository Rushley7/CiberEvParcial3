pipeline {
    agent any
    stages {
        stage('Construccion') {
            steps {
                dir('app') {
                    bat 'pip install -r requirements.txt'
                    bat 'python create_db.py'
                    echo 'Aplicacion construida correctamente'
                }
            }
        }
        stage('Pruebas') {
            steps {
                dir('app') {
                    bat 'python -c "import vulnerable_app; print(chr(39)+chr(39)+chr(39)+chr(39)+chr(39))"'
                    echo 'Verificando que la app no tenga errores de sintaxis'
                }
            }
        }
        stage('Despliegue') {
            steps {
                dir('app') {
                    bat 'docker build -t task-manager-app .'
                    bat 'docker rm -f task-manager-app-test || exit 0'
                    bat 'docker run -d --name task-manager-app-test -p 5000:5000 task-manager-app'
                }
            }
        }
    }
}