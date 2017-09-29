# Install jars for Jenkins swarm

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path "C:\jenkins_swarm.ps1.log" -append

# Jenkins swarm
$swarm_url = "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.4/swarm-client-3.4.jar"
Invoke-WebRequest $swarm_url -OutFile "C:/swarm-client.jar" -UseBasicParsing

Stop-Transcript