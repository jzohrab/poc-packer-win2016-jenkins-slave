# Runs the swarm-client jar.
# Sample call:
# & .\start_slave.ps1 -master_ip 10.1.0.98 -label sensei_build
param(
  [Parameter(Mandatory=$true)][string]$master_ip,
  [Parameter(Mandatory=$true)][string]$label
)

# "swarmslave" text is important:
# - role-based strategy in Jenkins master adds this item to the "slavenode" group
# - API control
$name = "swarmslave_${env:computername}"

# anonymous access for swarmslave
$swarm_client_cmd = "java -jar C:/swarm-client.jar " `
  + "-disableSslVerification " `
  + "-master 'http://${master_ip}:8080' " `
  + "-executors 1 -fsroot 'C:\Jenkins' " `
  + "-name ${name} " `
  + "-labels $label " `
  + "-mode exclusive " `
  + "-disableClientsUniqueId"

echo $swarm_client_cmd
iex $swarm_client_cmd