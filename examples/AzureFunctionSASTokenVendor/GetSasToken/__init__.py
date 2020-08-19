import datetime, json, os

import azure.functions as func
import azure.storage.blob as blob

account_name = os.environ['AZURE_STORAGE_ACCOUNT_NAME']
account_key = os.environ['AZURE_STORAGE_ACCOUNT_KEY']
container_name = os.environ['AZURE_STORAGE_CONTAINER_NAME']

def main(req: func.HttpRequest) -> func.HttpResponse:
    client_id = req.params.get('client_id')
    req_container = req.params.get('container')
    req_path = req.params.get('path')
    if not client_id or not req_container or not req_path:
        return func.HttpResponse("Bad Request", status_code=400)

    # In a real-world scenario, authenticate the client against your backend
    # infrastructure before proceeding further. Since the process of
    # authenticating clients is unique to each customer, it is omitted in this
    # sample.

    req_container = req_container.strip('/')
    req_path = req_path.strip('/')
    if req_container != container_name or not req_path.startswith(f'{client_id}/'):
        return func.HttpResponse("Bad Request", status_code=400)

    try:
        # Generate tokens that start now and are valid for 1 hour
        start = datetime.datetime.utcnow().replace(microsecond=0, tzinfo=datetime.timezone.utc)
        expiry = start + datetime.timedelta(hours=1)

        # Generate a token that permits the designated client to upload the requested file
        token = blob.generate_blob_sas(
            account_name,
            req_container,
            req_path,
            account_key=account_key,
            permission="w",
            expiry=expiry,
            start=start
        )

        return func.HttpResponse(json.dumps({
            'destination': f'https://{account_name}.blob.core.windows.net/{req_container}/{req_path}',
            'token': token,
            'valid_from': start.isoformat(),
            'valid_to': expiry.isoformat()
        }))
    except Exception as e:
        return func.HttpResponse(str(e), status_code=500)
