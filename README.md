# tf_cp_aws_tgwgwlb
<BR>
<BR>Please see your AWS credential before you run the terraform
<BR>Use the command "deploy.sh" to deploy
<BR>I split the terraform into two because I am hitting a bug when using depends_on in data.aws_subnet
<BR>If you want to remove the deployment
<BR>Use "remove.sh"
<BR>
<BR>Remember to change the password hash, SIC in the common.tfvars and use your own key file
<BR>In each checkpoint folder, there are a key.tf that have the public key in it
<BR>Change this if you wan to use your own key
