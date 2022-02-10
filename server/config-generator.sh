#!/bin/bash
set -e

BAD='\u001b[1m\u001b[31m'
GOOD='\u001b[1m\u001b[32m'
OK='\u001b[0m'


function help {
  echo "Run \"./act.sh [KEYS] DOMAIN\" with following keys:"
  echo "    DOMAIN - the domain name this server is running on (example: 'example.com'), required!"
  echo "  KEYS:"
  echo "    '-h' to see this message again"
  echo "    '-u' to set initial superuser email, default: 'admin@site.com'"
  echo "    '-p' to set initial superuser password, default: (will be generated)"
  echo "    '-f' to set output config file name, default: './config.env'"
  echo "  NB! all these params will be easily accessible and modifiable in generated output file."
  exit
}

function random {
  if [ "$PYTHON_AVAILABLE" = true ]; then
    python3 -c "import secrets; print(secrets.token_urlsafe(${1:-100}))"
  else
    echo '12345678'
  fi
}

function certificate {
  openssl req -x509 -newkey rsa:4096 -keyout ./certificates/"$1"_key.pem -out ./certificates/"$1"_cert.pem -sha256 -nodes -days 3650 -subj "/C=RU/ST=Ru/L=Test/O=Test/CN=localhost"
}


# Checking flags and setting defaults

if [ $# -eq 0 ]; then help; fi

DJANGO_SUPERUSER_EMAIL="admin@site.com"
DJANGO_SUPERUSER_PASSWORD="$(random 10)"
OUTPUT_FILE="./config.env"

while getopts "hu:p:f:" flag; do
  case "$flag" in
    h) help;;
    u) DJANGO_SUPERUSER_EMAIL="${OPTARG}";;
    p) DJANGO_SUPERUSER_PASSWORD="${OPTARG}";;
    f) OUTPUT_FILE="${OPTARG}";;
    *) help;;
  esac
done
shift $(( OPTIND - 1 ))

DJANGO_HOST="$1"


# Checking python environment

{
  python3 -c "import secrets" &> /dev/null
  PYTHON_AVAILABLE=true
} || {
  echo -e "${BAD}Python (>=3.6) is unavailable in current environment, so passwords will be set simple${OK}"
  PYTHON_AVAILABLE=false
}


# Checking OpenSSL availability

{
  openssl version -v &> /dev/null && echo "Generating SSL and TLS certificates (in ./certificates directory)"
  SSL_AVAILABLE=true
} || {
  echo -e "${BAD}OpenSSL is not available! SSL certificates won't be generated. Consider visiting https://www.openssl.org/source/ in order to get it.${OK}"
  SSL_AVAILABLE=false
}


# Generating SSL and TLS certificates

if [ $SSL_AVAILABLE ]; then
  if [ ! -d "./certificates" ]; then
    mkdir -p "./certificates";
  else
    if [ ! -w "./certificates" ]; then echo -e "${BAD}Directory ./certificates is not writable!${OK}"; fi
  fi
  certificate "ssl" &> /dev/null
  certificate "tls" &> /dev/null
  echo -e "${GOOD}Certificates generated!${OK}"
fi


# Checking specified domain name (first argument)

echo "Argument $DJANGO_HOST is recognized as a domain name"
{
  ping -c 3 "$DJANGO_HOST" &> /dev/null && echo -e "${GOOD}Hostname reached!${OK}"
} || {
  echo -e "${BAD}Could not reach host, aborting!${OK}"
  exit
}


# Checking email (first argument)

echo "Argument $DJANGO_SUPERUSER_EMAIL is recognized as a superuser email address"
regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
if [[ $DJANGO_SUPERUSER_EMAIL =~ $regex ]]; then
    echo -e "${GOOD}Email looks valid!${OK}"
    echo "Superuser password will be set to '$DJANGO_SUPERUSER_PASSWORD'"
else
    echo -e "${BAD}Argument ($DJANGO_SUPERUSER_EMAIL) is not a valid email address!${OK}"
    exit
fi


# Setting other required variables

POSTGRES_DB="hogweedgo"
POSTGRES_USER="admin"
POSTGRES_PASSWORD="$(random 10)"
echo "Postgres superuser name will be '$POSTGRES_USER', password '$POSTGRES_PASSWORD', database name: '$POSTGRES_DB'"

DJANGO_SECRET="$(random 100)"
echo "Django secret key will be set to '$DJANGO_SECRET'"


# Writing configs to output file

echo "Configurations will be written to $OUTPUT_FILE"
{
  touch "$OUTPUT_FILE" &> /dev/null
} || {
  echo -e "${BAD}File is not writable!${OK}"
  exit
}

echo "DJANGO_SECRET=$DJANGO_SECRET
DJANGO_HOST=$DJANGO_HOST

DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL
DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD

POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD" > "$OUTPUT_FILE"
echo -e "${GOOD}File written successfully!${OK}"
