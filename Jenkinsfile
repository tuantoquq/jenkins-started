pipeline {
  agent any

  environment {
    REGISTRY_CREDENTIALS = "registry_credentials"
    GIT_CREDENTIALS = "git_credentials"
    REGISTRY = "tuantoquq"
    DOCKER_IMAGE = ""
    BACKEND_HOST = "18.142.121.226"
    SSH_USERNAME = "ubuntu"
    IMAGE_NAME = "sample-next-app"
    IMAGE_TAG = "latest"
    CONTAINER_NAME = "sample-next-app"
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
        sh "docker tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
        sh "docker push $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
      }
    }

    stage ("Deploying") {
      steps {
        sh "echo 'Deploying the app'"
        sshagent (credentials: ['backend-ssh-server']) {
          withCredentials([usernamePassword(credentialsId: "$REGISTRY_CREDENTIALS", usernameVariable: 'DOCKERHUB_CREDENTIALS', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
            sh '''#!/bin/bash
              ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$BACKEND_HOST << EOF
                echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_CREDENTIALS --password-stdin
                docker pull $REGISTRY/$IMAGE_NAME:$IMAGE_TAGWWWWW
              << EOF
            '''
            
            echo "Removing the container if exists"
            script {
              def containerExist = sh(script: "ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$BACKEND_HOST docker ps -q -f name=$CONTAINER_NAME", returnStdout: true) == 0
              if (containerExist) {
                sh "ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$BACKEND_HOST docker stop $CONTAINER_NAME"
                sh "ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$BACKEND_HOST docker rm $CONTAINER_NAME"
              }
            }

            echo "Deploying the app"
            sh "ssh -o StrictHostKeyChecking=no $SSH_USERNAME@$BACKEND_HOST docker run -d -p 3000:3000 --name $CONTAINER_NAME $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
          }
        }
      }
    }
  }

  post {
      always {
          sh "echo 'Cleaning up the environment'"
          sh "docker images"
          sh "docker image rm $IMAGE_NAME:$IMAGE_TAG"
          sh "docker image rm $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
          sh "docker logout"
      }
  }
}