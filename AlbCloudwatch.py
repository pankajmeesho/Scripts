import boto3

cloudwatch_client = boto3.client('cloudwatch', region_name='ap-southeast-1')
sns_topic_arn = 'arn:aws:sns:ap-south-1:605536185498:devops'

metricName = 'HTTPCode_ELB_5XX_Count'

alblist = boto3.client('elbv2')
bals = alblist.describe_load_balancers()


#def get_albs():
#    alb_list = []
#    for alb in bals['LoadBalancerDescriptions']:
#        alb_list.append(alb['LoadBalancerName'])

#    print(alb_list)
#    return alb_list

alb_list=['meesho-production-alb']

def create_alarm():
    print('Creating alarm for ALB')
    for alb_name in alb_list:
        response = cloudwatch_client.put_metric_alarm(
            AlarmName='%s-High-%s' % (alb_name, metricName),
            AlarmDescription='alarm for testing',
            MetricName=metricName,
            Namespace='AWS/ApplicationELB',
            Statistic='Average',
            Dimensions=[
                {
                    'Name': 'LoadBalancerName',
                    'Value': alb_name
                }
            ],
            Period=300,
            Unit='Count',
            EvaluationPeriods=1,
            Threshold=1.0,
            ComparisonOperator='GreaterThanOrEqualToThreshold',
            ActionsEnabled=True,
            AlarmActions=[sns_topic_arn],
        )


if __name__ == "__main__":
    create_alarm()
