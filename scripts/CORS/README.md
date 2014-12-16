KVM scripts
===========

## Generic scripts

### kvmCreate.sh
#### Description
Creates a new environment-scoped keyvaluemap in an Apigee environment.

#### Usage
```./kvmCreate.sh {environment} {payloadFile} {username} [{password}]```

#### Parameters
environment: prod|test
payloadFile: name of file containing payload for KVM; if "-", uses standard input
username: email address of person creating KVM
password: (optional) for use by scripts -- will also prompt for password

### kvmSetData.sh
#### Description
Sets field(s) in an environment-scoped keyvaluemap in an Apigee environment.

#### Usage
```./kvmSetData.sh {environment} {payloadFile} {username} [{password}]```

#### Parameters
environment: prod|test
payloadFile: name of file containing payload for KVM; if "-", uses standard input
username: email address of person creating KVM
password: (optional) for use by scripts -- will also prompt for password

### originsKVMSet.sh
#### Description
Converts and uploads CORS origins whitelist to environment-specific Apigee config KVM.

#### Usage
```./originsKVMSet.sh {environment} {originsListFile} {username} [{password}]```

#### Parameters
environment: prod|pciprod|test|qa|dev
originsListFile: name of file containing whitelist; if "-", uses standard input
username: email address of person creating KVM
password: (optional) for use by scripts -- will also prompt for password

#### Notes
- cleans whitelist file
 - removes whitespace, blank lines and comments
 - sets everything to lowercase
 - strips trailing slashes on origins
 - alphabetically sorts file
- concatenates whitelisted origins and builds KVM payload file
- automatically calls kvmSetData.sh
