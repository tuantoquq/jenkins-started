pipeline {
  agent any

  environment {
    REGISTRY_CREDENTIALS = "registry_credentials"
    GIT_CREDENTIALS = "git_credentials"
    REGISTRY = "tuantoquq"
    DOCKER_IMAGE = ""
    BACKEND_HOST = "18.142.121.226"
    SSH_USERNAME = "ubuntu"
  }

  stages {
    stage ("Building") {
      steps {
        sh "echo 'Building the app'"
        sh "docker build -t sample-next-app:latest ./sample-app"
      }
    }

    stage ("Login to Docker Hub") {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: "$REGISTRY_CREDENTIALS", usernameVariable: 'DOCKERHUB_CREDENTIALS', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
            sh "echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_CREDENTIALS --password-stdin"
          }
        }
      }
    }

    stage ("Pushing" ){
      steps {
        sh "echo 'Pushing the image to Docker Hub'"
        sh "docker tag sample-next-app:latest $REGISTRY/sample-next-app:latest"
        sh "docker push $REGISTRY/sample-next-app:latest"
      }
    }

    stage ("Deploying") {
      steps {
        sh "echo 'Deploying the app'"
        sshagent (credentials: ['backend-ssh-server']) {
          withCredentials([usernamePassword(credentialsId: "$REGISTRY_CREDENTIALS", usernameVariable: 'DOCKERHUB_CREDENTIALS', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
            sh '''
              ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$BACKEND_HOST << EOF
                echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_CREDENTIALS --password-stdin
                docker pull $REGISTRY/sample-next-app:latest
                docker run -d -p 3000:3000 --name sample-next-app $REGISTRY/sample-next-app:latest
              EOF
            '''
          }
        }
      }
    }
  }

  post {
      always {
          sh "echo 'Cleaning up the environment'"
          sh "docker images"
          sh "docker image rm sample-next-app:latest"
          sh "docker logout"
      }
  }
}