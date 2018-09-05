def notify = { ->
  if (env.BRANCH_NAME == 'production' ||
      env.BRANCH_NAME == 'master') {
    message = "veterans-employment-center ${env.BRANCH_NAME} branch CI failed. |${env.RUN_DISPLAY_URL}".stripMargin()
    slackSend message: message,
    color: 'danger',
    failOnError: true
  }
}

node('vetsgov-general-purpose') {
  properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', daysToKeepStr: '60']]]);

  stage('Setup') {
    checkout scm
    sh "docker-compose build"
  }
  stage('Ensure database exists') {
    sh "docker-compose -p vec up -d"
    sh "docker-compose -p vec run veteran-employment-center bundle exec rake db:create db:schema:load db:migrate"
  }
  stage('Update bundle-audit database') {
    sh "docker-compose -p vec run veteran-employment-center bundle exec bundle-audit update"
  }
  stage('Run tests') {
    try {
      sh "docker-compose -p vec run veteran-employment-center bundle exec rake"
      sh "docker-compose -p vec run veteran-employment-center bundle exec brakeman"
      sh "docker-compose -p vec run veteran-employment-center bundle exec bundle-audit"
    } catch (err) {
      notify()
      throw err
    } finally {
      sh "docker-compose -p vec down --remove-orphans"
      step([$class: 'JUnitResultArchiver', testResults: 'coverage'])
    }
  }
}
