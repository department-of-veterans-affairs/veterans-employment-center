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
  def imageTag

  stage('Setup') {
    imageTag = java.net.URLDecoder.decode(env.BUILD_TAG).replaceAll("[^A-Za-z0-9\\-\\_]", "-")
    checkout scm
  }
  stage('Ensure database exists') {
    sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec up -d && docker-compose -p vec run veteran-employment-center bundle exec rake db:create db:schema:load db:migrate"
  }
  stage('Update bundle-audit database') {
    sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec run veteran-employment-center bundle exec bundle-audit update"
  }
  stage('Run tests') {
    try {
      sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec run veteran-employment-center bundle exec rake"
      sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec run veteran-employment-center bundle exec brakeman"
      sh "export IMAGE_TAG=${imageTag} && docker-compose -p vec run veteran-employment-center bundle exec bundle-audit"
    } catch (err) {
      notify()
      throw err
    } finally {
      sh "docker-compose -p vec down --remove-orphans"
    }
  }
}
