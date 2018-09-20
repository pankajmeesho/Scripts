import boto3
from botocore.exceptions import ClientError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import sys

# Cleans unused eips from all region

################################Mail list to dvo####################################################
sender = "pankaj.kumar@meesho.com"
recipients = ["pankaj.kumar@meesho.com","sanjeev@meesho.com"]
mail_subject = "Lambda Janitor: List of eip(s) removed from AWS"
mail_body = "Attached file contains list of eip(s) which are removed from AWS"
attachments = {"eip_list.txt": "/tmp/file1.txt"}
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


session = boto3.session.Session()
region_client = session.client('ec2', region_name='ap-southeast-1')
regions_response = region_client.describe_regions()

ses_client = boto3.client('ses', region_name=aws_region)


def lambda_handler(event, context):
    # write deleted eips to file
    file = open('/tmp/file1.txt', "w")
    file.write("Lambda janitor: clean_eips \n\n")

    eips = []

    for regions in regions_response["Regions"]:
        region = regions["RegionName"]
        allocation_ids = {}

        ec2 = session.client('ec2', region_name=region)
        response = ec2.describe_addresses()
        for addresses in response["Addresses"]:
            try:
                if addresses["NetworkInterfaceId"]:
                    a = 1

            # skipping as IP address is in use
            except (ClientError, KeyError) as e:
                allocation_id = addresses["AllocationId"]
                public_ip = addresses["PublicIp"]
                allocation_ids[allocation_id] = public_ip

                if len(allocation_ids) > 0:
                    print ("[" + region + "]::The following Elastic IPs are not in use:")
                    file.write("[" + region + "]::The following Elastic IPs are not in use:\n")
                    for aid in allocation_ids:

                        try:
                            eip = session.client('ec2', region_name=region)
                            eip.release_address(AllocationId=aid)
                            print (allocation_ids[aid] + " deleted!")
                            eips.append(allocation_ids[aid])
                            file.write(allocation_ids[aid] + " deleted!\n")
                        except ClientError as e:
                            print (e.response['Error']['Code'] + " " + aid)
                            # file.write(e.response['Error']['Code'] + " " + aid + "\n")
                    file.write("\n\n")

    file.close()

    # send mail with attachment
    if not eips:
        print ("No eips found")
    else:

        responses = send_mail(
            sender,
            recipients,
            mail_subject,
            mail_body,
            attachments,
            ses_client)

        print(responses)

    return 'EIPs deleted'