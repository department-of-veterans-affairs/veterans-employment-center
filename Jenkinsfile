def notify = { ->
  if (env.BRANCH_NAME == production ||
      env.BRANCH_NAME == master) {
    message = "veterans-employment-center ${env.BRANCH_NAME} branch CI failed. |${env.RUN_DISPLAY_URL}".stripMargin()
    slackSend message: message,
    color: 'danger',
    failOnError: true
  }
}

pipeline {
  agent {
    label 'vetsgov-general-purpose'
  }

  stages {
    stage('Setup') {
      steps {
        properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', daysToKeepStr: '60']]]);
        def imageTag
        imageTag = java.net.URLDecoder.decode(env.BUILD_TAG).replaceAll("[^A-Za-z0-9\\-\\_]", "-")
        checkout scm
      }
    }

    stage('Ensure database exists') {
      steps {
        sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec up -d && docker-compose -p vec run --rm bundle exec rake db:create db:schema:load db:migrate"
      }
    }

    stage('Update bundle-audit database') {
      steps {
        sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec up -d && docker-compose -p vec run --rm bundle exec bundle-audit update"
      }
    }

    stage('Run tests') {
      steps {
        try {
          parallel (
            rake: {
              sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec up -d && docker-compose -p vec run --rm bundle exec rake"
            },
            brakeman: {
              sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec up -d && docker-compose -p vec run --rm bundle exec brakeman"
            },
            bundleaudit: {
              sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec up -d && docker-compose -p vec run --rm bundle exec bundle-audit"
            }
          )
        } catch (err) {
            notify()
          throw err
        } finally {
          sh "docker-compose -p vec down --remove-orphans"
        }
      }
    }
  }
}
