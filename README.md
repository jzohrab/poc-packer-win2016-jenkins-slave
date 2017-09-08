# packer-win-aws

Proof-of-Concept Packer template for provisioning a Jenkins slave
windows instance on EC2 using Powershell over WinRM / https.

Builds on work from Vincent Rivellino and Peter Goodman, ref
http://blog.petegoo.com/2016/05/10/packer-aws-windows/.

## Usage

See template.json for the list of variables needed.

Ensure you have a security group set up with RDP ingress:

    $ aws ec2 create-security-group --group-name devenv-sg --description "sec group" --vpc-id <id>
    # record the group ID
    {
       "GroupId": "sg-<id>"
    }

    # enable RDP
    $ aws ec2 authorize-security-group-ingress --group-id sg-<id> --protocol tcp --port 3389 --cidr <cidr>
    $ aws ec2 authorize-security-group-ingress --group-id sg-<id> --protocol udp --port 3389 --cidr cidr>

    $ aws ec2 create-key-pair --key-name devenv-key --query "KeyMaterial" --output text > devenv-key.pem

Packer:

    $ packer validate -var-file=./vars/aws_creds.json -var-file=./vars/win_ami_base.json template.json
    # OK

    # exporting the debug info to try to get the password.
    $ export PACKER_LOG=1
    $ export PACKER_LOG_PATH=packerlog.log
    $ packer build -var-file=./vars/aws_creds.json -var-file=./vars/win_ami_base.json template.json

    Created: us-east-1: ami-<id>

    # Launch from CLI or from console, RDP in and try to build.

    $ aws ec2 run-instances --image-id ami-<id> --subnet-id subnet-<id> --security-group-ids sg-<id> --count 1 --instance-type t2.micro --key-name devenv-key --query "Instances[0].InstanceId"
    "i-<id>"

    $ aws ec2 describe-instances --instance-ids "i-<id>" --query "Reservations[0].Instances[0].PublicIpAddress"
    "<ip>"

    # RDP to <ip> following instructions at
      http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/connecting_to_windows_instance.html


## Todo

* Fix tags (ref template.json "tags") - should be more sensible

* Jenkins has a plugin to auto-spawn EC2 slaves
  (https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Plugin), but
  it's not clear if it works for Windows per the comment history.  If
  not, will try Jenkins swarm per
  http://kevops.info/2016-12-04-bootstrap-jenkins-dsc/

* can automatically get the created AMI's ID per gist
  https://gist.github.com/irgeek/2f5bb964e3ce298e15b7