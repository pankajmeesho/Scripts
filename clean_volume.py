import boto3
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

# function lists for volume with 'Available' state and exempts those with tag 'DND'

####################################################################################
sender = "pankaj.kumar@meesho.com"
recipients = ["pankaj.kumar@meesho.com","sanjeev@meesho.com"]
mail_subject = "Lambda Janitor: List of EBS volumes in 'Available state'"
mail_body = "Attached file contains list of AWS volume(s) which needs to be cleaned"
attachments = {"ebs_list.txt": "/tmp/file.txt"}
aws_region = "eu-west-1"


def send_mail(senders: str, recipients: list, title: str, body: str, attachments: dict, client: object) -> list:
    # create raw email
    msg = MIMEMultipart()
    msg['Subject'] = title
    msg['From'] = senders

    part = MIMEText(body)
    msg.attach(part)

    for attachment in attachments:
        part = MIMEApplication(open(attachments[attachment], 'rb').read())
        part.add_header('Content-Disposition', 'attachment', filename=attachment)
        msg.attach(part)

    # end create raw email
    responses = []
    for recipient in recipients:
        # important: msg['To'] has to be a string. If you want more than one recipient,
        # you need to do sth. like ", ".join(recipients)
        msg['To'] = recipient
        response = client.send_raw_email(
            Source=senders,
            Destinations=[recipient],  # here it has to be a list, even if it is only one recipient
            RawMessage={
                'Data': msg.as_string()  # this generates all the headers and stuff for a raw mail message
            })
        responses.append(response)
    return responses


###########################################################################################
ses_client = boto3.client('ses', region_name=aws_region)

# volume state to look for
volume_state = ['available']

vol = []

# regions to clean ebs volume
ebs_regions = ["ap-southeast-1"]


def lambda_handler(event, context):
    file = open('/tmp/file.txt', "w")
    file.write("::Lambda janitor: clean_volumes:: \n\n")

    for i in range(len(ebs_regions)):
        client = boto3.client('ec2', region_name=ebs_regions[i])
        response = client.describe_volumes(Filters=[{'Name': 'status', 'Values': volume_state}])

        file.write("For " + ebs_regions[i] + " following volumes are not in use:\n")

        for each_volume in response['Volumes']:
            if 'Tags' in each_volume:
                dnd_flag = False
                for tag in each_volume['Tags']:
                    if tag['Key'] == 'DND':
                        dnd_flag = True
                        continue
                if not dnd_flag:
                    # print each_volume['VolumeId']
                    vol.append(each_volume['VolumeId'])
                    file.write(each_volume['VolumeId'] + '\n')
                    print(each_volume['VolumeId'])
                    response1 = client.delete_volume(
                        VolumeId=each_volume['VolumeId'],
                    )
                    print(response1)

            else:
                # print each_volume['VolumeId']
                vol.append(each_volume['VolumeId'])
                file.write(each_volume['VolumeId'] + '\n')
                print(each_volume['VolumeId'])
                    response1 = client.delete_volume(
                        VolumeId=each_volume['VolumeId'],
                    )
                    print(response1)

        file.write('\n\n')

    file.close()

    if not vol:
        print ("No volumes found")
    else:

        responses = send_mail(
            sender,
            recipients,
            mail_subject,
            mail_body,
            attachments,
            ses_client)

        print(responses)

    return "Job executed"