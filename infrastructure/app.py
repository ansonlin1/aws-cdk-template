#!/usr/bin/env python
import os
from uuid import uuid4
from time import time

from aws_cdk import App, Environment

from lib.stages.stage import AwsStage
from lib.utils.deploy_glue_resources import deploy_glue_resources


def main():
    app = App()

    account_name = os.environ.get("ACCOUNT_NAME")
    account_number = os.environ.get("ACCOUNT_NUMBER")
    env_name = os.environ.get("ENV_NAME")
    region = os.environ.get("REGION")
    stage_type = os.environ.get("STAGE_TYPE")
    github_repo_name = os.environ.get("GITHUB_REPO_NAME")

    short_stack_name = 'test-stack'
    stack_name = ''.join([account_name, short_stack_name])

    lambda_code_folder = os.path.join(os.path.dirname(__file__), '..', 'software', 'src')
    lambda_handler = 'test_lambda.test_lambda.event_handler'

    glue_etl_src_location = f'{github_repo_name}/{int(time())}-{uuid4().hex[:5]}'
    glue_job_handler_files = [
        '../software/src/...'
    ]

    if not os.environ.get('SYNTH'):  # Don't set SYNTH to deploy glue resources
        src_dir_path = '../software/src'
        deploy_glue_resources(glue_job_handler_files, glue_etl_src_location, src_dir_path)

    props = {
        'account_name': account_name,
        'account_num': account_number,
        'env_name': env_name,
        'region': region,
        'stage_type': stage_type,
        'short_stack_name': short_stack_name,
        'stack_name': stack_name,
        'lambda_code_folder': lambda_code_folder,
        'lambda_handler': lambda_handler,
    }

    main.stage = AwsStage(
        app, f'{env_name}-{stage_type}',
        env=Environment(account=account_number, region=region),
        **props
    )

    app.synth()


if __name__ == "__main__":
    main()
