import boto3

# Create CloudWatch client

cloudwatch = boto3.client('cloudwatch', region_name='ap-southeast-1')
sns_topic_arn = 'arn:aws:sns:ap-southeast-1:847438129436:devops'

def create_alarm():
   print('Creating alarm for ALB')
   response = cloudwatch.put_metric_alarm(
   AlarmName='Test-CPUCredit-Low',
   AlarmDescription='Testing for low cpu credit alaram',
   MetricName='CPUCreditBalance',
   Namespace='AWS/EC2',
   Statistic='Maximum',
   Dimensions=[
        {
          'Name': 'InstanceId',
          'Value': 'i-0b9be561ce7097913'
        },
    ],
   Period=60,
   Unit='Count',
   EvaluationPeriods=1,
   Threshold=1.0,
   ComparisonOperator='GreaterThanOrEqualToThreshold',
   ActionsEnabled=True,
   AlarmActions=[sns_topic_arn],
   )

if __name__ == "__main__":
    create_alarm()