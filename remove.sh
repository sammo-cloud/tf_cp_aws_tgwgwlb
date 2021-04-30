cd tgw
terraform init
terraform destroy -var-file ../common.tfvars --auto-approve 
cd ..
cd checkpoint
terraform init 
terraform destroy -var-file ../common.tfvars --auto-approve 
cd ..
