# terraform-webserver-azure
Sample webserver deployment on `Azure` with `Terraform` with a `Python` health check script.

# Deploy the Nginx webserver on CentOS using Terraform

Please run the following commands on `Linux` enviromnent to test the deployment of a sample Hello World webserver.

```
# This demo has been excuted on Terraform v1.1.8 and Python 3.7.3 on Linux (Azure Cloud Shell)
terraform -version
python --version

# Download the code repo
git clone https://github.com/proarhant/terraform-webserver-azure.git && cd terraform-webserver-azure

# Generate SSH key pair for this demo deployment...
ssh-keygen -P "" -t rsa -C "This SSH kay pair is for demo purpose only" -f ./id_rsa_tfadmin
```
![image](https://user-images.githubusercontent.com/2681229/165100334-2997933e-0017-4a99-9bbb-791f1e920b3e.png)
```
# Now, lets deploy the webserver with Terraform
terraform init
terraform apply
terraform refresh
# Confirm that the webserver is serving the Hello World! page.
curl `terraform output -raw public_ip`
```
After the completion of `terraform apply`, please make sure to run `terraform refresh` to deal with the issue detailed here: https://github.com/hashicorp/terraform-provider-azurerm/issues/159. 

![image](https://user-images.githubusercontent.com/2681229/165114439-00f7f200-d668-42c4-901a-c4a894b91eb4.png)
![image](https://user-images.githubusercontent.com/2681229/165114729-4b672691-6fb4-4b57-bfb7-08aeaced82e8.png)

Enter `yes` to accept the provisioning to be carried out by `Terraform`. In our automation script, we will use `terraform apply --auto-approve`.

![image](https://user-images.githubusercontent.com/2681229/165115560-9dc836f1-4f70-4000-a1fe-c71090a3d77b.png)

The deployment will show the `Public IP` of the deployed server. This IP info is valuable for us to use in the automation and test scripts.

![image](https://user-images.githubusercontent.com/2681229/165101479-79669c9d-c984-4495-a4b3-c3789d21238b.png)
```
# Confirm that the webserver is serving the Hello World! page.
curl `terraform output -raw public_ip`
```
![image](https://user-images.githubusercontent.com/2681229/165102564-5c27ef63-20ee-4dcb-821e-39c07f2f331e.png)
![image](https://user-images.githubusercontent.com/2681229/165102932-450be9b1-5a36-4b94-9285-1e117aa21097.png)

# Deploy the Python Health Check script to monitor webserver status

The health check script named `healthcheck.py` takes two arguments: `public ip of the webserver` and `health check interval`.

Optionally, the script can also be installed as a `crontab` job on `Linux` or `Task Scheduler` job on `Windows` to run periodically.

Please ensure that only one instance of the script runs at any given time.

The checks are done on the health conditions including following:
1. Nginx process is down e.g. Host is up but HTTP response is not retrieved.
2. Host server is down e.g. not reachable.
3. Nginx is not serving. E.g. index.html is missing, or not readable.
https://github.com/proarhant/terraform-webserver-azure/blob/9166f572c3974d35e84ba3b77db0741c2859c848/health-check-scripts/healthcheck.py#L36-L53

In this example, the script checks the health condition of the server every 5 seconds.
```
# Periodically check the health of the webserver every 5 seconds
HEALTH_CHECK_PERIOD=5
nohup python ./health-check-scripts/healthcheck.py `terraform output -raw public_ip` $HEALTH_CHECK_PERIOD > healthcheck_webapp.out 2>&1 &

# Start monitoring the webapp
tail -f healthcheck_webapp.log
```
We can monitor the contents of the health check script's log file named `healthcheck_webapp.log` using `tail -f healthcheck_webapp.log`.

![image](https://user-images.githubusercontent.com/2681229/165104483-31c27b9a-9324-4e6f-8789-54f9a5b95902.png)

We will destroy all remote objects managed by our demo Terraform configuration
```
terraform destroy
```
# Build and Deploy using WebserverDeployAndHealthcheck.sh
The bash script named `WebserverDeployAndHealthcheck.sh` can be used to aumoate the steps executed above:
```
chmod +x WebserverDeployAndHealthcheck.sh 
./WebserverDeployAndHealthcheck.sh
```

The scrit will execute the following steps:

1. Deploy the `Hello World` webserver on CentOS.
2. Configure the `Python` health check script to run periodically `every 5 seconds`.
3. Monitor the health condition with `tail -f healthcheck_webapp.log`.


