pipeline {
    agent any

    stages {
      stage ("Build") {
        steps {
            sh "echo 'Building the app'"
            sh "docker build -t sample-next-app:latest ./sample-app"
        }
      }

      stage ("Push" ){
          steps {
              sh "echo 'Pushing the app'"
              sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
              sh "docker push sample-next-app:latest"
          }
      }

      stage ("Deploy") {
          steps {
              sh "echo 'Deploying the app'"
              sshagent (credentials: ['ssh-credentials']) {
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker pull sample-next-app:latest"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker stop sample-next-app"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker rm sample-next-app"
                  sh "ssh -o StrictHostKeyChecking=no -l root" + " " + "docker run -d -p 3000:3000 --name sample-next-app sample-next-app:latest"
              }
          }
      }
    }
}