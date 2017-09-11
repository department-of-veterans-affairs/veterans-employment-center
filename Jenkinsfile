pipeline {
  agent { label 'vetsgov-general-purpose' }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Install bundle') {
      steps {
        sh 'bash --login -c "bundle install -j 4 --without development"'
      }
    }

    stage('Ensure database exists') {
      steps {
        sh 'bash --login -c "bundle exec rake db:create db:schema:load db:migrate"'
      }
    }

    stage('Update bundle-audit database') {
      steps {
        sh 'bash --login -c "bundle exec bundle-audit update"'
      }
    }

    stage('Run tests') {
      steps {
        sh 'bash --login -c "bundle exec rake"'
        sh 'bash --login -c "bundle exec brakeman"'
        sh 'bash --login -c "bundle exec bundle-audit"'
      }
    }
  }
}
