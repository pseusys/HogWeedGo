import argparse
import json
import random
import time
from datetime import datetime
from string import ascii_lowercase

import requests


parser = argparse.ArgumentParser(description="Generate reports.")
parser.add_argument('port', nargs='?', default=8000,  type=int, help="the hogweed server API port")
parser.add_argument('reports', nargs='?', default=1000, type=int, help="how many reports should generate")
parser.add_argument('--users', '-u', nargs='?', default=1, const=1, dest="users", type=int, help="how many reports should belong to one user")


start_timestamp = int(time.mktime(datetime.strptime("01/01/2022", "%d/%m/%Y").timetuple()))
end_timestamp = int(time.mktime(datetime.strptime("31/12/2022", "%d/%m/%Y").timetuple()))


def random_letters(a: int, b: int) -> str:
    return "".join(random.choices(ascii_lowercase, k=random.randint(a, b)))


def generate_user(number: int) -> str:
    random.seed(number)

    email = f'{random_letters(5, 10)}@{random_letters(3, 6)}.{random_letters(2, 4)}'
    prove_response = requests.get(f'http://localhost:{args.port}/api/me/prove_email?email={email}')
    assert prove_response.status_code == 200, "Server returned unexpected status code (email proving)!"

    code = prove_response.json()['message'].split('"')[1]
    password = random_letters(1, 20)
    user_response = requests.get(f'http://localhost:{args.port}/api/me/auth?email={email}&code={code}&password={password}')
    assert prove_response.status_code == 200, "Server returned unexpected status code (user creation)!"

    return user_response.text


def generate_report(number: int, code: str):
    random.seed(number)

    auth = {'authorization': code}
    report = {
        'init_comment': random_letters(10, 100),
        'address': random_letters(5, 25),
        'type': f'hogweed | {random.randint(0, 100)}%',
        'date': random.randint(start_timestamp, end_timestamp),
        'place': {
            'lat': random.randint(-900000000, 900000000) / 10000000,
            'lng': random.randint(-1800000000, 1800000000) / 10000000
        }
    }
    data = {'data': json.dumps(report)}

    photos = []
    for i in range(0, random.randint(1, 10)):
        photo_response = requests.get(f'https://source.unsplash.com/random?sig={number + i}')
        ext = photo_response.headers['Content-Type'].split('/')[1]
        if ext in ('jpg', 'jpeg', 'png'):
            photos += [('photos', (f'photo{number + i}.{ext}', photo_response.content))]

    response = requests.post(f'http://localhost:{args.port}/api/reports', data=data, files=photos, headers=auth)
    assert response.status_code == 201, "Server returned unexpected status code (report creation)!"


args = parser.parse_args()
assert args.users > 0, "Users number should be > 0"
assert args.reports >= 0, "Users number should be >= 0"
assert args.reports % args.users == 0, "Reports number should be dividable by users number"

reports_per_user = args.reports // args.users
for user_num in range(0, args.users):
    token = generate_user(user_num)
    for report_num in range(0, reports_per_user):
        generate_report(report_num * args.reports + user_num, token)
        print(f"Reports generated: {reports_per_user * user_num + report_num + 1} / {args.reports}")
