import boto3
from sh import sort
from sh import tee


session = boto3.session.Session(region_name='ap-southeast-1')
ec2 = session.client('ec2')

fp = open('production-hosts', 'w')

filters = [
    {
        'Name': 'instance-state-name',
        'Values': [
            'running',
        ]
    },

]
response = ec2.describe_instances(Filters=filters)
for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        for tag in instance["Tags"]:
            if tag["Key"] in "Name":
                try:
                    if "devops" not in tag["Value"] and "vpn" not in tag["Value"]:
                        fp.write(tag["Value"] + " ansible_host=" + instance["PrivateIpAddress"] + " ansible_user=conman ansible_ssh_private_key_file=~/.ssh/keys/conman_id_rsa\n")

                except KeyError:
                    print tag["Value"] + instance["KeyName"]

fp.close

#sort the invetory file
tee(sort("production-hosts"), "production-hosts")


