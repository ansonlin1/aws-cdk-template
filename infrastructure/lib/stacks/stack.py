import logging

from constructs import Construct
from aws_cdk import (
    Environment,
    Stack,
    Duration,
    aws_lambda
)

log = logging.getLogger(__name__)


class AwsStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, env: Environment, **kwargs) -> None:
        super().__init__(scope, construct_id, env=env, stack_name=kwargs['stack_name'])

        aws_lambda.Function(
            self, 'rTestLambda',
            code=aws_lambda.Code.from_asset(kwargs['lambda_code_folder']),
            handler=kwargs['lambda_handler'],
            runtime=aws_lambda.Runtime.PYTHON_3_8,
            timeout=Duration.seconds(60),
            environment={
                "ACCOUNT_NAME": kwargs['account_name']
            }
        )
