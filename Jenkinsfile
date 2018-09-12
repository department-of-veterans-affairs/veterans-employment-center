def notify = { ->
  if (env.BRANCH_NAME == 'production' ||
      env.BRANCH_NAME == 'master') {
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
        checkout scm
        sh "docker-compose build --no-cache --force-rm"
      }
    }
    stage('Ensure database exists') {
      steps {
        sh "docker-compose -p vec up -d"
        sh "docker-compose -p vec run veteran-employment-center bundle exec rake db:create db:schema:load db:migrate"
      }
    }
    stage('Update bundle-audit database') {
      steps {
        sh "docker-compose -p vec run veteran-employment-center bundle exec bundle-audit update"
      }
    }
    stage('Run tests') {
      steps {
        script {
          try {
            sh "docker-compose -p vec run veteran-employment-center bundle exec rake"
            sh "docker-compose -p vec run veteran-employment-center bundle exec brakeman"
          } catch (err) {
            notify()
            throw err
          }
        }
      }
    }
    stage('Run bundle-audit') {
      steps {
        script {
          try {
            sh "docker-compose -p vec run veteran-employment-center bundle exec bundle-audit"
          } catch (err) {
            println err
          }
        }
      }
    }
  }
  post {
    always {
      println "Cleaning up Docker images"
      sh "docker-compose -p vec down --remove-orphans"
    }
  }
}

