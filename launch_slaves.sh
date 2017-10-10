# Creates one or more slaves reporting to the master node,
# using the same subnet, key, and security groups as the master.
#
# Sample call:
#   <scriptname> 10.50.11.211 ami-326ea948 2
#
# NOTE: This could be changed to an autoscaling group,
# but since the first job run of a slave is potentially
# very expensive (due to the full cloning of GitHub in the
# first run of any klick-genome job), it is (currently) better
# to Stop and then Start instances.

if [ $# != 3 ]; then
    echo -e "Usage: $0 <master_private_ip> <ami_id> <number_of_instances>"
    exit 1
fi

MASTERIP=$1
AMIID=$2
COUNT=$3

# AWS CLI text output is hard to parse:
# make a few separate calls to get characteristics of
# master node.
function get_cmd() {
    KEY=$1
    echo "aws ec2 describe-instances \
    --filters Name=private-ip-address,Values=$MASTERIP \
    --query 'Reservations[0].Instances[0].[$1]' \
    --output text"
}

SUBNET_ID=`eval $(get_cmd SubnetId)`
KEYNAME=`eval $(get_cmd KeyName)`
SECGROUPS=`eval $(get_cmd "SecurityGroups[*].GroupId")`
KEYNAME=jenkins

echo
echo Creating $COUNT instances of $AMIID reporting to $MASTERIP :
echo "   Subnet: $SUBNET_ID"
echo "   Key: $KEYNAME"
echo "   Security groups: $SECGROUPS"
echo

aws ec2 run-instances \
    --image-id $AMIID \
    --region us-east-1 \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SECGROUPS \
    --associate-public-ip-address \
    --iam-instance-profile Name=s3-readonly-access \
    --count $COUNT \
    --instance-type m4.large \
    --key-name $KEYNAME \
    --user-data "<powershell>& C:\start_slave.ps1 -master_private_ip $MASTERIP -label sensei_build</powershell><persist>true</persist>" \
    --query "Instances[*].InstanceId"
