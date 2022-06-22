# Sample Python program to illustrate HMAC Authentication

import sys
import base64
import hashlib
import hmac
from datetime import datetime
        
def sign_request(appID,
                secret,    
                url,      
                method):
    verb = method.upper()

    utc_now = str(datetime.utcnow().strftime("%b, %d %Y %H:%M:%S ")) + "GMT"

    # String-To-Sign
    string_to_sign = appID + '\n' + \
                    verb + '\n' + \
                    url + '\n' + \
                    utc_now   
    # Decode secret
    decoded_secret = base64.b64decode(secret, validate=True)
    digest = hmac.new(decoded_secret, bytes(string_to_sign, 'utf-8'), hashlib.sha256).digest()

    # Signature
    signature = base64.b64encode(digest).decode('utf-8')

    print ("HMAC-SHA256 " + signature)
sign_request(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
