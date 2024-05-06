import os
import pathlib
import zipfile

from aws_cdk.assertions import Template
import boto3
import yaml


def deploy_glue_resources(
        handlers: [str],
        deployment_artifact_prefix: str,
        src_directory: str
) -> None:
    artifact_bucket_name = ''

    # create archive
    src_directory = pathlib.Path(src_directory)
    with zipfile.ZipFile('etl_src.zip', mode='w') as archive:
        for file_path in src_directory.rglob("*"):
            archive.write(file_path, arcname=file_path.relative_to(src_directory))

    # send archive to s3
    with open(os.path.join(os.getcwd(), 'etl_src.zip'), 'rb') as zip_file:
        boto3.client('s3').put_object(
            Bucket=artifact_bucket_name,
            Key=f'{deployment_artifact_prefix}/etl_src.zip',
            Body=zip_file
        )

    # send handlers to s3
    for file in handlers:
        last_slash_location = file.rfind('/')
        destination_key = f'{deployment_artifact_prefix}/{file[last_slash_location + 1:]}'

        boto3.client('s3').upload_file(
            Bucket=artifact_bucket_name,
            Key=destination_key,
            Filename=file
        )


def print_template_as_yaml(template: Template):
    template_as_yaml = yaml.dump(template.to_json())
    print(template_as_yaml)


def snake_to_pascal(snake_str: str) -> str:
    return ''.join([word.lower().capitalize() for word in snake_str.split('_')])


def snake_to_camel(snake_str: str) -> str:
    first, *others = snake_str.split('_')
    return ''.join([first.lower(), *map(str.title, others)])
