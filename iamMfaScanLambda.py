import boto3
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication


####################################################################################
sender = "pankaj.kumar@meesho.com"
recipients = ["pankaj.kumar@meesho.com","rohitpatel@meesho.com"]
mail_subject = "Lambda Janitor: List of IAM Users Without MFA"
mail_body = "Attached file contains list of IAM user without MFA Which needs enable"
attachments = {"iam_list.txt": "/tmp/file5.txt"}
aws_region = "eu-west-1"
ses_client = boto3.client('ses', region_name=aws_region)


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



def lambda_handler(context,event):
    
    client                  = boto3.client('iam')
    sns                     = boto3.client('sns')
    response                = client.list_users()
    userVirtualMfa          = client.list_virtual_mfa_devices()
    mfaNotEnabled           = []
    virtualEnabled          = []
    physicalString          = ''
    ignore_user = {'dynamo_db_prod', 'whatsapp_engagement', 'codeship', 'ses-smtp-user.20180815-112208', 'ses-smtp-user.20180815-113317', 'dynamo_db_dev', 'meesho-danger-script', 'grafana', 'meesho_code_deploy', 'ses', 'meesho_upload', 'admin', 'activation', 'notifications_lambda', 'sensu-aws-api-ro', 'manifest-service', 'meesho_notifications', 'ecs-cli-dev'}
    
    file = open('/tmp/file5.txt', "w")
    file.write("::Lambda janitor: IAM Users:: \n\n")
    
    # loop through virtual mfa to find users that actually have it
    for virtual in userVirtualMfa['VirtualMFADevices']:
        virtualEnabled.append(virtual['User']['UserName'])
           
    # loop through users to find physical MFA
    for user in response['Users']:
        userMfa  = client.list_mfa_devices(UserName=user['UserName'])
        
        if len(userMfa['MFADevices']) == 0:
            if user['UserName'] not in virtualEnabled:
                mfaNotEnabled.append(user['UserName']) 
    
    mfaNotEnabledSet=set(mfaNotEnabled)
    mfaNotEnabledList=list( mfaNotEnabledSet - ignore_user )
    
    
    if len(mfaNotEnabledList) > 0:
        #physicalString = 'MFA is not enabled for the following users: \n\n' + '\n'.join(mfaNotEnabledList)
        for iam in mfaNotEnabledList:
            file.write("%s\n" % iam)
        file.write('\n\n')
        file.close()    
    else:
        #physicalString = 'All Users have Virtual MFA enabled'
        file.write("All Users have Virtual MFA enabled\n")
        file.write('\n\n')
        file.close()
        
    responses = send_mail(
            sender,
            recipients,
            mail_subject,
            mail_body,
            attachments,
            ses_client)

    return "Job executed"
