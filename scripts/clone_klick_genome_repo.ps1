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

# Don't worry about "Win32Exception encountered ... Failed to write
# credentials" exception.  We're cloning this as a reference,
# and don't need to update it or use these creds again.

git clone --progress https://${username}:${password}@github.com/KlickInc/klick-genome.git
