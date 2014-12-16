#! /bin/bash

usageStr="Usage: kvmSetData.sh {environment} {payloadFile} {kvmName} {user}"

if [[ -z "$1" ]]; then
  echo $usageStr
  exit
fi

# replace with your org
org=myorg

env=$1
payloadFile=$2
kvmName=$3
user=$4

if [[ -z "$5" ]]; then
  echo "Enter your password for Apigee Edge, followed by [ENTER]:"
  read -s password
else
  password=$5
fi

verb=PUT
url=https://api.enterprise.apigee.com
userPw=$user:$password
echo
echo "Setting KVM data in $env (Apigee org $org, env $env)"
echo

cat $payloadFile | tr '\t' ' ' | sed 's/^ *//;s/ *$//' | tr '\n' ' ' | curl -q -v -u $userPw -X $verb -H "Content-Type: application/json" -d @- "$url/v1/o/$org/e/$env/keyvaluemaps/$kvmName"
