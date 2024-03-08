pipeline {
  agent any

  environment {
      REGISTRY_CREDENTIALS = "registry_credentials"
      GIT_CREDENTIALS = "git_credentials"
      REGISTRY = "tuantoquq"
      DOCKER_IMAGE = ""
      GITHUB_URL = "https://github.com/tuantoquq/jenkins-started"
      GIT_BRANCH = "main"
  }

  stages {
    stage ("Checkout") {
      steps {
        sh "echo 'Checking out the code'"
        git branch:"$GIT_BRANCH", credentialsId: "$GIT_CREDENTIALS", url: "$GITHUB_URL"
      }
    }
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

  post {
      always {
          sh "echo 'Cleaning up the environment'"
          sh "docker images"
          sh "docker image rm sample-next-app:latest"
          sh "docker logout"
      }
  }
}