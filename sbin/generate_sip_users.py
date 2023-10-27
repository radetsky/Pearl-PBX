import random
import string

# Function to generate a random 10-character password
def generate_random_password():
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(10))

# Number of SIP users to create
num_users = 200

# Template for SIP user configuration
template = """
[{user_id}]
type=friend
secret={password}
context=ITTVOffice
host=dynamic
canreinvite=no
call-limit=4
"""

# Generate and print SIP user configurations to STDOUT
for user_id in range(1600, 1600 + num_users):
    password = generate_random_password()
    print(template.format(user_id=user_id, password=password))

