# packer-win-aws

Packer template for provisioning a Jenkins slave windows instance on
EC2 using Powershell over WinRM / https.

Builds on work from Vincent Rivellino and Peter Goodman, ref
http://blog.petegoo.com/2016/05/10/packer-aws-windows/.

## Usage

See template.json for the list of variables needed.

Ensure you have a security group set up with RDP ingress (tcp and udp, port 3389).

Packer:

    $ REPO=`git remote get-url origin` \
      SHA=`git log -n 1 --format=%h` \
      packer validate \
      -var='region=us-east-1' \
      -var='instance_type=m4.large' \
      -var-file=./zz_aws_secret.json \
      template.json

    $ REPO=`git remote get-url origin` \
      SHA=`git log -n 1 --format=%h` \
      packer build \
      -var='region=us-east-1' \
      -var='instance_type=m4.large' \
      -var-file=./zz_aws_secret.json \
      template.json


## Todo

* Fix tags (ref template.json "tags") - should be more sensible
