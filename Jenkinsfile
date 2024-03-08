pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('Jenkins-Docker-Hub')
    }

    stages {
      stage ("Build") {
        steps {
            sh "echo 'Building the app'"
            sh "docker build -t sample-next-app:latest ./sample-app"
        }
      }

      stage ("Login Docker Hub") {
          steps {
              sh "echo 'Logging into Docker Hub'"
              sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
          }
      }

      stage ("Push" ){
          steps {
              sh "echo 'Pushing the image to Docker Hub'"
              sh "docker push sample-next-app:latest"
          }
      }

      stage ("Deploy") {
          steps {
              sh "echo 'Deploying the app'"
              sshagent (credentials: ['ssh-credentials']) {
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker login -u $DOCKERHUB_CREDENTIALS --password-stdin"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker pull sample-next-app:latest"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker stop sample-next-app"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker rm sample-next-app"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker run -d -p 3000:3000 --name sample-next-app sample-next-app:latest"
              }
          }
      }
    }
}