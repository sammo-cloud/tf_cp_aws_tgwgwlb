cd checkpoint
terraform init 
terraform apply -var-file ../common.tfvars --auto-approve 
cd ..
cd tgw
terraform init
terraform apply -var-file ../common.tfvars --auto-approve 
cd ..
