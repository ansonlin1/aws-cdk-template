from aws_cdk import Environment, Stage
from constructs import Construct

from lib.stacks.stack import AwsStack


class AwsStage(Stage):
    def __init__(self, scope: Construct, construct_id: str, env: Environment, **kwargs) -> None:
        super().__init__(scope, construct_id)

        self.aws_stack = AwsStack(
            self,
            kwargs['stack_name'],
            env=Environment(account=env.account, region=env.region),
            **kwargs
        )
        # self.aws_stack.template_options.transforms = ["disaster_recovery_transform"]
