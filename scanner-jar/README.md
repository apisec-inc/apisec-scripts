# Deploying APIsec Scanner as a jar file
## Prerequisite: 
Java-17, FX_HOST, FX_IAM & FX_KEY from APIsec scanner


Please use the below commands for deploying the APIsec Scanner as a jar file. Make sure to update the placeholders <FX_HOST>, <FX_IAM>, and <FX_KEY>.

## on Windows machine with Powershell.
```.\Scanner_Jar_Deployment.ps1 -fx_host "<FX_HOST>" -fx_iam "<FX_IAM>" -fx_key "<FX_KEY>"```

## on Ubuntu machine.
```./Scanner_Jar_Deployment.sh --fx-host "<FX_HOST>" --fx-iam "<FX_IAM>" --fx-key "<FX_KEY>"```