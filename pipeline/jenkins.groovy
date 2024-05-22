pipeline {
    agent any
    parameters {
        choice(name: 'OS', choices: ['linux', 'arm', 'macos', 'windows'], description: 'OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Архитектура')
    }

    environment {
        GITHUB_TOKEN=credentials('kaathepython')
        REPO = 'https://github.com/kaathepython/telebot.git'
        BRANCH = 'main'
    }

    stages {

        stage('clone') {
            steps {
                echo 'cloning'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage('test') {
            steps {
                echo 'testing'
                sh "make test"
            }
        }

        stage('image') {
            steps {
                echo "building image for OS: ${params.OS} arch: ${params.ARCH}"
                sh "make image-${params.OS} ${params.ARCH}"
            }
        }

        stage('build') {
            steps {
                echo "building binary ${params.OS} for arch ${params.ARCH}"
                sh "make ${params.OS} ${params.ARCH}"
            }
        }
       
        stage('login to GHCR') {
            steps {
                sh "echo $GITHUB_TOKEN_PSW | docker login ghcr.io -u $GITHUB_TOKEN_USR --password-stdin"
            }
        }

        stage('push image') {
            steps {
                sh "make -n ${params.OS} ${params.ARCH} image push"
            }
        } 
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}