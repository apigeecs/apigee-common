if [[ -z "$1" ]]; then
  echo "Usage: configKVMCreate.sh {env} {user}"
  exit
fi

env=$1
user=$2

if [[ -z "$3" ]]; then
  echo "Enter your password for Apigee Edge, followed by [ENTER]:"
  read -s password
else
  password=$3
fi

./kvmCreate.sh $env apiConfig_Create.json $user $password
