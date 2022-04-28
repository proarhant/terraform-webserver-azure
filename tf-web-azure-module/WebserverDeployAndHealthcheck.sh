#!/bin/bash

# Deploy a VM on Azure using Terraform

# Before we run this script, please get the source code from repo.
# echo -e "\033[42;10mGetting the code downloaded from GitHub...\e[0m"
# git clone https://github.com/proarhant/terraform-webserver-azure.git && cd terraform-webserver-azure

# Generate SSH key pair
echo -e "\033[42;10mGenerating SSH key pair for this demo deployment...\e[0m"
ssh-keygen -P "" -t rsa -C "This SSH kay pair is for demo purpose only" -f ./id_rsa_tfadmin
sleep 3

# Using Terraform, deploy the webserver on Azure
echo ""
echo -e "\033[42;10mProvisioning the webserver using Terraform...\e[0m"
echo ""
sleep 3 
terraform init
terraform apply -auto-approve

# Refreshing the state terraform refresh to deal with this issue: https://github.com/hashicorp/terraform-provider-azurerm/issues/159
echo ""
echo -e "\033[42;10mRefresh Terrafrom state...\e[0m"
echo ""
#terraform apply -refresh-only -auto-approve
terraform refresh

# Let Azure take some time to spin up the VM
echo ""
echo -e "\033[42;10mLet Azure take about a minute to configure the VM...\e[0m"
echo ""
sleep 58

echo -e "\033[42;10mNow lets run the health check periodically every 5 seconds...\e[0m"
echo ""
# Health check periodically every 5 seconds
HEALTH_CHECK_PERIOD=5

nohup python ./health-check-scripts/healthcheck.py `terraform output -raw public_ip` $HEALTH_CHECK_PERIOD > healthcheck_webapp.out 2>&1 &
sleep 3
# Start monitoring the webapp
tail -f healthcheck_webapp.log
