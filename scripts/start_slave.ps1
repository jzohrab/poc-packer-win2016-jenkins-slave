# Runs the swarm-client jar, connecting to the master's private IP.
#
# Sample call:
# & .\start_slave.ps1 -master_private_ip 10.1.0.98 -label sensei_build
#
# According to the docs, Jenkins slaves should be able to auto-discover
# the master (ref https://wiki.jenkins.io/display/JENKINS/Auto-discovering+Jenkins+on+the+network),
# but this currenty fails in our AWS setup despite permissive
# internal security group settings:
#   WARNING: Failed to receive a reply to broadcast.
#   java.net.SocketTimeoutException: Receive timed out
#
param(
  [Parameter(Mandatory=$true)][string]$master_private_ip,
  [Parameter(Mandatory=$true)][string]$label
)

# "swarmslave" text is important:
# - role-based strategy in Jenkins master adds this item to the "slavenode" group
# - API control
$name = "swarmslave_${env:computername}"

# Ref https://wiki.jenkins.io/display/JENKINS/Swarm+Plugin for options.
$swarm_client_cmd = "java -jar C:/swarm-client.jar " `
  + "-disableSslVerification " `
  + "-master 'http://${master_private_ip}:8080' " `
  + "-executors 1 -fsroot 'C:\Jenkins' " `
  + "-name ${name} " `
  + "-labels $label " `
  + "-mode exclusive " `
  + "-disableClientsUniqueId"

echo $swarm_client_cmd
iex $swarm_client_cmd