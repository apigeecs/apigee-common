#! /bin/bash

usageStr="Usage: originsKVMSet.sh {environment} {user}"
kvmName="apiConfig"
prodFile="ProdWhitelist.txt"
nonProdFile="NonProdWhitelist.txt"

if [[ -z "$1" ]]; then
  echo $usageStr
  exit
fi

environment=$1
user=$2

# validate environment
if [ "$environment" != "prod" ] && [ "$environment" != "test" ] ;
then
  echo "Invalid environment $environment specified."
  echo $usageStr
  exit
fi

# choose originsListFile
originsListFile=$nonProdFile
if [ "$environment" = "prod" ] ;
then
  originsListFile=$prodFile
fi

if [[ -z "$3" ]]; then
  echo "Enter your password for Apigee Edge, followed by [ENTER]:"
  read -s password
else
  password=$3
fi

originsStr=`cat $originsListFile | tr '\r' '\n' | sed '/^#/d' | sed 's/#.*$//' | tr -d " \t" | sed 's/\/$//' | sed '/^$/d' | tr '[:upper:]' '[:lower:]' | sort | uniq | paste -d '|' -s -`
originsStr="s#REPLACETHIS#|$originsStr|#"

cat apiConfig_DataTemplate.json | sed "$originsStr" | ./kvmSetData.sh $environment - $kvmName $user $password

echo
echo "#"
echo "# Deployed $originsListFile to $kvmName KVM in $environment"
echo "#"
