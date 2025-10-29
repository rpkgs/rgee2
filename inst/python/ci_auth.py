# https://github.com/gee-community/ee-initialize-github-actions/blob/main/README.md
import os
import ee
import json
import google.oauth2.credentials


def auto_Initialize(token):
    # with open("token.json", "r") as f:
    #     stored = json.load(f)
    stored = json.loads(token)

    credentials = google.oauth2.credentials.Credentials(
        None,
        token_uri="https://oauth2.googleapis.com/token",
        client_id=stored["client_id"],
        client_secret=stored["client_secret"],
        refresh_token=stored["refresh_token"],
        quota_project_id=stored["project"],
    )

    ee.Initialize(credentials=credentials)
    print("Hello, Earth Engine!")
    return credentials
