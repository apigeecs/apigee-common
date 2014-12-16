#!/bin/sh

# commonDeploy.sh <apiName> <commonVersion> <localPomDir> <environment> <username> [<password>]
api=$1
commonVersion=$2
localPomDir=$3
environment=$4
username=$5
password=$6

if [[ -z "$password" ]]; then
  echo "Enter your password for Apigee Edge, followed by [ENTER]:"
  read -s password
fi

#Allow this to be run outside of jenkins and provide build information
if [ -z "$BUILD_TAG" ]; then
  BUILD_TAG=localbuild-`hostname`-`date +%s`
fi

commonDeployDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# find list of files being pulled from common
cd $commonDeployDir/../edge/$commonVersion/apiproxy
commonFilesArray=("$(find . -type f -print | sed 's#^\./##')")

# exit if conflicting file in API
abort=0
for fileName in ${commonFilesArray[@]}
do
	if [ -e "$localPomDir/apiproxy/$fileName" ]
	then
		echo "ERROR: File $fileName is in both $api and the $commonVersion common files."
		abort=1
	fi
done
if [ "$abort" -eq 1 ]
then
	exit 1
fi

#change to localPomDir
cd $localPomDir

#Sync the proxy with Apigee common policies
rsync -a $commonDeployDir/../edge/$commonVersion/apiproxy .

#remove unused common policies
#echo "[COMMON] Removing unused common policies and resources"
policySearchString="/NOMATCH "
resourceSearchString="/NOMATCH "
policyArray=()
policyFileArray=()
resourceFileArray=()
resourceStringArray=()

for fileName in ${commonFilesArray[@]}
do
	#echo $fileName
	if [[ $fileName == policies/* ]]
	then
		policyName="$(xmllint --xpath 'string(/*/@name)' $localPomDir/apiproxy/$fileName)"
		policySearchString+="| //Step/Name[text()=\"$policyName\"] "
		policyArray+=($policyName)
		policyFileArray+=($fileName)
	else
		resourceName=$( basename $fileName )
		resourceType=$( basename $(dirname $fileName) )
		resourceString="$resourceType://$resourceName"
		resourceSearchString+="| //IncludeURL[text()=\"$resourceString\"] | //ResourceURL[text()=\"$resourceString\"] "
		resourceFileArray+=($fileName)
		resourceStringArray+=($resourceString)
	fi
done

# find all matching policies
foundPolicies="$( (echo "<ROOT>" ; cat $localPomDir/apiproxy/proxies/* $localPomDir/apiproxy/targets/* ; echo "</ROOT>") | sed 's/<\?.*\?>//' | xmllint --xpath "$policySearchString" - )"

for (( i = 0 ; i < ${#policyFileArray[@]} ; i++ ))
do
	fileName=${policyFileArray[$i]}
	policyName=${policyArray[$i]}
	policyStr="<Name>$policyName</Name>"
	if [[ $foundPolicies != *$policyStr* ]]
	then
		#echo "[COMMON] Policy $policyName not used, removing."
		rm -f $localPomDir/apiproxy/$fileName
	else
		echo "[COMMON] Policy $policyName included."
	fi
done

# find all matching resources in policies
foundResources=$( ( echo "<ROOT>" ; cat $localPomDir/apiproxy/policies/* ; echo "</ROOT>" ) | sed 's/<\?.*\?>//' | xmllint --xpath "$resourceSearchString" -  )

#remove unused resources
for (( i = 0 ; i < ${#resourceFileArray[@]} ; i++ ))
do
	fileName=${resourceFileArray[$i]}
	resourceStr=${resourceStringArray[$i]}
	if [[ $foundResources != *$resourceStr* ]]
	then
		#echo "[COMMON] Resource $fileName not used, removing."
		rm -f $localPomDir/apiproxy/$fileName
	else
		resourceName=$( basename $fileName )
		echo "[COMMON] Resource $resourceName included."
	fi
done

#Execute maven deployment, using settings file from common resources.
mvn install -P$environment -Dusername=$username -Dpassword=$password

if [ "$?" -ne 0 ]
then
  echo "\n[ERROR] No notification sent, maven failed!"
elif [ "$environment" = "prod" ]
then
  # Send instant message notification for prod deployments, example below is hipchat
  # Replace with your IM solution
  notifyMessage="Deployment Notification: $api deployed to $environment environment - $BUILD_TAG"
  echo "\nSending HipChat Notification... \"$notifyMessage\""
  #curl -s -o /dev/null https://api.hipchat.com/v1/rooms/message -d "auth_token=<authTokenHere>" -d "from=ApigeeBot" -d "message=$notifyMessage" -d "color=yellow" -d "room_id=<roomNameHere>"
fi

# delete remaining common files
for fileName in ${commonFilesArray[@]}
do
	rm -f $localPomDir/apiproxy/$fileName
done

# Maven plugin creates a temp directory named 'target'.  Remove this after the deployment.
rm -rf target
