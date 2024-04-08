# run this before running the script on windows

# $env:GOOGLE_APPLICATION_CREDENTIALS='c:/users/bolexyro/downloads/file.json'
# on macos / linux
# export GOOGLE_APPLICATION_CREDENTIALS="/home/user/Downloads/service-account-file.json"

# to read more
# https://firebase.google.com/docs/cloud-messaging/auth-server#linux-or-macos

import firebase_admin
from firebase_admin import credentials, messaging

cred = credentials.Certificate("c:/users/bolexyro/desktop/text call/text_call/text-call-7f4b1-4496d34751a0.json")
default_app = firebase_admin.initialize_app(cred)
registration_token = 'dxUZaIXHQFuRYWFG3GcIqe:APA91bGhYsVojYc7oWKD69X0D0-xr7nTidQlXpPmlqEEeEtgthBMIOgS8ZYD2DSxdZro6cvi-16ctbc-_sMnR8YJ7JJqL0AyuEeDKREfF5NrTNHi_KLie6DdAdTd3lYJ8HNHBVHtf3vN'

# See documentation on defining a message payload.
message = messaging.Message(
    notification=messaging.Notification(title='No one is calling', body='It is not important', image='https://cdn.nba.com/headshots/nba/latest/1040x760/203507.png'),
   
    token=registration_token,
)

# Send a message to the device corresponding to the provided registration token.
response = messaging.send(message)
# Response is a message ID string.
print('Successfully sent message:', response)