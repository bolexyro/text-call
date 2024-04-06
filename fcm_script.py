# run this before running the script on windows

# $env:GOOGLE_APPLICATION_CREDENTIALS='c:/users/bolexyro/downloads/file.json'
# on macos / linux
# export GOOGLE_APPLICATION_CREDENTIALS="/home/user/Downloads/service-account-file.json"

# to read more
# https://firebase.google.com/docs/cloud-messaging/auth-server#linux-or-macos

import firebase_admin
from firebase_admin import credentials, messaging

# cred = credentials.Certificate()
default_app = firebase_admin.initialize_app()
registration_token = 'cQR9udz6SHmH1ChwTww8Pb:APA91bH0mlfiU285u1awLbKxvv7d2ASHrj4PbpTESJrwK9fRQ4BynxKk9jIKPK-ARrCJy-360A3VHugGdkkqQIf3TZxvNWIHk0t1toArvhdQFx0_6cYNaBF9jfeeAxlcdFRuAHHJHUFy'

# See documentation on defining a message payload.
message = messaging.Message(
    notification=messaging.Notification(title='No one is calling', body='It is not important', image='https://cdn.nba.com/headshots/nba/latest/1040x760/203507.png'),
   
    token=registration_token,
)

# Send a message to the device corresponding to the provided registration token.
response = messaging.send(message)
# Response is a message ID string.
print('Successfully sent message:', response)