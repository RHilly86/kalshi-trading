from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import base64
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding, rsa
from cryptography.exceptions import InvalidSignature
import requests
import datetime

def load_private_key_from_file(file_path):
    with open(file_path, "rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None,  # or provide a password if your key is encrypted
            backend=default_backend()
        )
    return private_key

def sign_pss_text(private_key: rsa.RSAPrivateKey, text: str) -> str:
    # Before signing, we need to hash our message.
    # The hash is what we actually sign.
    # Convert the text to bytes
    message = text.encode('utf-8')

    try:
        signature = private_key.sign(
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.DIGEST_LENGTH
            ),
            hashes.SHA256()
        )
        return base64.b64encode(signature).decode("utf-8")
    except InvalidSignature as e:
        raise ValueError("RSA sign PSS failed") from e

# Get the current time
current_time = datetime.datetime.now()

# Convert the time to a timestamp (seconds since the epoch)
timestamp = current_time.timestamp()

# Convert the timestamp to milliseconds
current_time_milliseconds = int(timestamp * 1000)
timestampt_str = str(current_time_milliseconds)

private_key = load_private_key_from_file("/Users/rhilly/market-trading.txt")
method = "GET"
base_url = "https://api.elections.kalshi.com/"
path = "/trade-api/v2/portfolio/balance"

msg_string = timestampt_str + method + path

sig = sign_pss_text(private_key, msg_string)

len(sig)

headers = {
        'KALSHI-ACCESS-KEY': "d8a1aef2-e376-4ba0-8a54-ada12eb1729b",
        'KALSHI-ACCESS-SIGNATURE': sig,
        'KALSHI-ACCESS-TIMESTAMP': timestampt_str
}

response = requests.get(base_url + path, headers=headers)
print("Status Code:", response.status_code)
print("Response Body:", response.text)