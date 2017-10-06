An Amazon EC2 Windows build slave provisioned using Packer.

This project has two main features:

* pre-provisioning of common build tools using Packer
* the Jenkins swarm plugin and a launch script for slaves
  to auto-register with the Jenkins master.

## Usage

### Building AMIs

    $ REPO=`git remote get-url origin` \
      SHA=`git log -n 1 --format=%h` \
      packer build \
      -var='region=us-east-1' \
      -var='instance_type=m4.large' \
      -var-file=./aws_secret.json \
      template.json

`packer verify` before you build.

See template.json for the list of variables needed.

### Launching instances

The slaves are provisioned with a startup script
(`scripts/start_slave.ps1`) which can be called as user data, e.g.:

    aws ec2 run-instances \
        --image-id $AMIID \
	...
        --user-data "<powershell>& C:\start_slave.ps1 -master_private_ip <ip_here> -label sensei_build</powershell><persist>true</persist>" \
        --query "Instances[*].InstanceId"

Use the script `launch_slaves.sh` to ensure that the slaves are in the
same subnet and security groups as the Jenkins master.

#### Connectivity and auto-registration

Jenkins will need to be configured specifically for slaves to
auto-register.  See
https://stackoverflow.com/questions/32886262/jenkins-swarm-plugin-authentication.

## Todo

* Fix tags (ref template.json "tags") - should be more sensible

## Refs

Builds on work from Vincent Rivellino and Peter Goodman, see
http://blog.petegoo.com/2016/05/10/packer-aws-windows/.
