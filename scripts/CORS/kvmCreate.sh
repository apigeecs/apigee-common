#! /bin/bash

usageStr="Usage: kvmCreate.sh {environment} {payloadFile} {user}"

if [[ -z "$1" ]]; then
  echo $usageStr
  exit
fi

# replace with your org
org=myorg

env=$1
payloadFile=$2
user=$3

if [[ -z "$4" ]]; then
  echo "Enter your password for Apigee Edge, followed by [ENTER]:"
  read -s password
else
  password=$4
fi

verb=POST
url=https://api.enterprise.apigee.com
userPw=$user:$password
echo
echo "Creating KVM in $env (Apigee org $org, env $env)"
echo

cat $payloadFile | tr '\t' ' ' | sed 's/^ *//;s/ *$//' | tr '\n' ' ' | curl -q -v -u $userPw -X $verb -H "Content-Type: application/json" -d @- "$url/v1/o/$org/e/$env/keyvaluemaps"
