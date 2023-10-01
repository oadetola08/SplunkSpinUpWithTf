import requests
import json
import sys
import time
from requests.exceptions import ConnectionError

max_retries = 3

# Disable SSL certificate verification
requests.packages.urllib3.disable_warnings()

# Retrieve the instance ID and instance IP address from the command-line arguments
instance_id = sys.argv[1]
instance_ip = sys.argv[2]

# Now, you can use the instance ID and instance IP address in your automation logic
print(f"Instance ID: {instance_id}")
print(f"Instance IP: {instance_ip}")

# Splunk Enterprise API endpoint for user creation
splunk_api_url = f"http://{instance_ip}:8089/services/authentication/users"

splunk_api_url_index = f"https://{instance_ip}:8089/services/data/indexes"


# Splunk credentials with appropriate privileges
splunk_username = "admin"
splunk_password = f"SPLUNK-{instance_id}"

# User information
new_user_name = "tola004_newUser"
new_user_password = "Kosmos0852-"

# Create a dictionary with user information
user_data = {
    "name": new_user_name,
    "password": new_user_password,
    "roles": "user"  # Specify the roles for the new user
}

# Send a POST request to create the user
for _ in range(max_retries):
    try:
        response = requests.post(
        splunk_api_url,
        data=json.dumps(user_data),
        auth=(splunk_username, splunk_password),
        headers={"Content-Type": "application/json"},
        verify=False,  # Disable SSL certificate verification
        timeout=180
        )
        # Check if the request was successful and break the loop
        if response.status_code == 201 or response.status_code == 200:
            print("User created successfully.")
            break
    except ConnectionError as e:
        print(f"Connection error: {e}")
        # Sleep for a moment before retrying
        time.sleep(5)



# Index configuration
index_name = "my_custom_index"
index_config = {
    "name": index_name,
    "datatype": "event",
    "blockSignSize": "auto",
    "maxTotalDataSizeMB": "50000",
    "homePath": "$SPLUNK_DB/defaultdb/db",
    "coldPath": "$SPLUNK_DB/defaultdb/colddb",
    "thawedPath": "$SPLUNK_DB/defaultdb/thaweddb"
}

# Send a POST request to create the index
for _ in range(max_retries):
    try:
        response = requests.post(
        splunk_api_url_index,
        data=json.dumps(index_config),
        auth=(splunk_username, splunk_password),
        headers={"Content-Type": "application/json"},
        verify=False,  # Disable SSL certificate verification
        timeout=180
        )
        # Check if the request was successful and break the loop
        if response.status_code == 201 or response.status_code == 200:
            print(f"Index '{index_name}' created successfully.")
            break
    except ConnectionError as e:
        print(f"Connection error: {e}")
        # Sleep for a moment before retrying
        time.sleep(5)
