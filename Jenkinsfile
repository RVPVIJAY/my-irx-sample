pipeline {
  agent { label 'worker-node' }   // change to your Windows agent's label
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Generate IRX') {
      steps { powershell 'powershell -ExecutionPolicy Bypass -File scripts\\generate_irx.ps1' }
    }
    stage('Configure Plugin') {
      steps { powershell 'powershell -ExecutionPolicy Bypass -File scripts\\configure_plugin.ps1' }
    }
  }
  post {
    success { archiveArtifacts artifacts: 'build/*.irx' }
  }
}
