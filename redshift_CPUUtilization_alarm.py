import boto3

cloudwatch_client = boto3.client('cloudwatch', region_name='ap-southeast-1')
sns_topic_arn = 'arn:aws:sns:ap-southeast-1:847438129436:shared-infra-alerts'
metricName = 'CPUUtilization'
redshiftCluster = 'meesho-dw'
description = 'The percent of CPUUtilization used.'
node_list = ['Compute-0', 'Compute-1', 'Compute-2', 'Compute3', 'Compute4', 'Compute-5', 'Compute-6', 'Compute-7', 'Compute-8', 'Compute-9', 'Compute-10', 'Compute-11', 'Compute-12', 'Compute-13', 'Compute-14', 'Compute-15']

def create_alarm():
    print('Creating alarm for Redis')
    for node in node_list:
        response = cloudwatch_client.put_metric_alarm(
        AlarmName='awsredshift-meesho-dw-High-%s-%s' % (metricName, node),
        AlarmDescription=description,
        MetricName=metricName,
        Namespace='AWS/Redshift',
        Statistic='Average',
        Dimensions=[
                {
                    'Name': 'NodeID',
                    'Value': node
                },
                {
                    'Name': 'ClusterIdentifier',
                    'Value': redshiftCluster
                }

            ],
        Period=300,
        Unit='Percent',
        EvaluationPeriods=1,
        Threshold=90.0,
        ComparisonOperator='GreaterThanOrEqualToThreshold',
        ActionsEnabled=True,
        AlarmActions=[sns_topic_arn],
        OKActions=[sns_topic_arn]
        )


if __name__ == "__main__":
    create_alarm()