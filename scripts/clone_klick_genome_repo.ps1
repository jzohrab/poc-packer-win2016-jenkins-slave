# Clones the klick-genome repo.
#
# The klick-genome repo is very heavy.  Pre-baking a clone into the AMI
# vastly speeds up the pipeline.
#
# Sample call:
# & .\clone_klick_genome_repo.ps1 -username blah -password blah
#
param(
  [Parameter(Mandatory=$true)][string]$username,
  [Parameter(Mandatory=$true)][string]$password
)

$ErrorActionPreference = 'Stop'

mkdir c:/reference_repo
cd c:/reference_repo

# Was getting "Win32Exception encountered ... Failed to write credentials" exception.
# https://stackoverflow.com/questions/43577576/git-bash-win32exception-failed-to-write-credentials
git config --global credential.helper manager

git clone --progress https://${username}:${password}@github.com/KlickInc/klick-genome.git
