from test_lambda.test_lambda import lambda_handler


def test_event():
    actual_response = lambda_handler({})
    assert actual_response == 'Hello from Lambda!'
