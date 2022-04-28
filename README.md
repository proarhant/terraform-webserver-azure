# terraform-webserver-azure
The deployment of a sample webserver on `Azure` with `Terraform` which is monitored with a health check script coded in `Python`.

The code in this repository serves following two puposes:
1. `Terraform` code will deploy a `Hello World` webserver on a `CentOS` VM hosted on `Azure`. The `Nginx` webserver deployed on the VM  will respond with `Hello World!` when the website is called e.g. command-line tools such as `curl` or browser.
2. `Python` code will run periodically e.g. `every 5 seconds` to check health of the webserver. The health check process will return `SUCCESS` if the website's `index.html` page contains `Hello World!` text.

The demo has been executed and tested on `Azure Cloud Shell` configured with `Terraform v1.1.8` and `Python 3.7.3`.

The `module version` of the `Terraform` code is placed under `tf-web-azure-module` directory. For information on the usage of the module, please see below at the end of this document.

# Deploy the Nginx webserver on CentOS using Terraform

Please run the following commands on `Linux` enviromnent to test the deployment of a sample Hello World webserver.

```
# This demo has been executed and tested on Terraform v1.1.8 and Python 3.7.3 on Linux (Azure Cloud Shell)
terraform -version
python --version

# Download the code repo
git clone https://github.com/proarhant/terraform-webserver-azure.git && cd terraform-webserver-azure

# Generate SSH key pair for this demo deployment...
ssh-keygen -P "" -t rsa -C "This SSH kay pair is for demo purpose only" -f ./id_rsa_tfadmin
```
![image](https://user-images.githubusercontent.com/2681229/165100334-2997933e-0017-4a99-9bbb-791f1e920b3e.png)

The `Terraform` code in this demo accomplishes following objectives:

1. First, provision the `CentOS` VM on `Auzre`
2. Then, deploy the sample `Hello World` webpage on `Nginx` webserver using the `custom data`.

In this`Terraform` code, the `custom_data` in `azurerm_virtual_machine` specifies the custom data to supply to the CentOS VM to install the `Nginx` software and then create the sample `Hello World!` webpage.

https://github.com/proarhant/terraform-webserver-azure/blob/cd9df9339a2e208f0526be7103878ccbea1167a4/main.tf#L105
https://github.com/proarhant/terraform-webserver-azure/blob/cd9df9339a2e208f0526be7103878ccbea1167a4/variables.tf#L60-L61
https://github.com/proarhant/terraform-webserver-azure/blob/cd9df9339a2e208f0526be7103878ccbea1167a4/cloud-init-scripts/centos_user_data.txt#L4-L12

The following `Terraform` commands will be executed to build the sample web server:
```
terraform init
terraform apply
terraform refresh
```
After the completion of `terraform apply`, please make sure to run `terraform refresh` to deal with the issue detailed here: https://github.com/hashicorp/terraform-provider-azurerm/issues/159. 

![image](https://user-images.githubusercontent.com/2681229/165114439-00f7f200-d668-42c4-901a-c4a894b91eb4.png)
![image](https://user-images.githubusercontent.com/2681229/165114729-4b672691-6fb4-4b57-bfb7-08aeaced82e8.png)

Enter `yes` to accept the provisioning to be carried out by `Terraform`. In our automation script, we will use `terraform apply --auto-approve`.

![image](https://user-images.githubusercontent.com/2681229/165115560-9dc836f1-4f70-4000-a1fe-c71090a3d77b.png)

The deployment will show the `Public IP` of the deployed server. This IP info is valuable for us to use in the automation and test scripts.

![image](https://user-images.githubusercontent.com/2681229/165101479-79669c9d-c984-4495-a4b3-c3789d21238b.png)

In this example, I am using `curl` command to hit the website's `public ip`. Please note that the `Python` script will take any ip associated with the webserver.
```
# Confirm that the webserver is serving the Hello World! page.
curl `terraform output -raw public_ip`
```
![image](https://user-images.githubusercontent.com/2681229/165102564-5c27ef63-20ee-4dcb-821e-39c07f2f331e.png)
![image](https://user-images.githubusercontent.com/2681229/165102932-450be9b1-5a36-4b94-9285-1e117aa21097.png)

# Deploy the Python Health Check script to monitor webserver status

The health check script named `healthcheck.py` stored in `health-check-scripts` direcrory takes two arguments: `ip of the webserver` and `health check interval`. The script is developed in `Python 3.7.3` version. 

Please note that the `Python` script will take any ip (public or private) associated with the webserver. The value for the`health check interval` period is given in `seconds`.

In this demo, I am using `public ip` to hit the website and script checks the health in `every 5 seconds`.
```
PUB_IP=`terraform output -raw public_ip`
HEALTH_CHECK_PERIOD=5
python ./health-check-scripts/healthcheck.py $PUB_IP $HEALTH_CHECK_PERIOD
```

The health check process will return `SUCCESS` if the website's `index.html` page contains `Hello World!` text.
https://github.com/proarhant/terraform-webserver-azure/blob/a63d62b4a00152c3bdfbbd4cfe5d2312a89a44b1/tf-web-azure-module/health-check-scripts/healthcheck.py#L41-L45

The error checks are done on the health conditions including following:
1. `Nginx process is down` e.g. Host is up but HTTP response is not retrieved.
2. `Host server is down` e.g. not reachable.
3. `Nginx is not serving` e.g. index.html is missing, or not readable.
https://github.com/proarhant/terraform-webserver-azure/blob/a63d62b4a00152c3bdfbbd4cfe5d2312a89a44b1/tf-web-azure-module/health-check-scripts/healthcheck.py#L53-L60

In this example, the script checks the health condition of the server `every 5 seconds`. The first argument is the `public ip` of the website.
```
# Periodically check the health of the webserver every 5 seconds
HEALTH_CHECK_PERIOD=5
nohup python ./health-check-scripts/healthcheck.py `terraform output -raw public_ip` $HEALTH_CHECK_PERIOD > healthcheck_webapp.out 2>&1 &

# Start monitoring the webapp
tail -f healthcheck_webapp.log
```
We can monitor the contents of the health check script's log file named `healthcheck_webapp.log` using `tail -f healthcheck_webapp.log`.

![image](https://user-images.githubusercontent.com/2681229/165104483-31c27b9a-9324-4e6f-8789-54f9a5b95902.png)

Please ensure that only one instance of the script runs at any given time. Optionally, the script can also be installed as a `crontab` job on `Linux` or `Task Scheduler` job on `Windows` to run periodically.

Once we complete the `demo`, we will destroy all remote objects managed by our `Terraform` configuration:
```
terraform destroy
```
# Build and Deploy using WebserverDeployAndHealthcheck.sh
The bash script named `WebserverDeployAndHealthcheck.sh` can be used to aumoate the steps manually executed above:
```
# Download the code from GitHub repo
git clone https://github.com/proarhant/terraform-webserver-azure.git && cd terraform-webserver-azure
# Make the script executable and run
chmod +x WebserverDeployAndHealthcheck.sh 
./WebserverDeployAndHealthcheck.sh
```
![image](https://user-images.githubusercontent.com/2681229/165186215-36251a9f-e355-431c-8dca-61231e80bccd.png)
The scrit will execute the following steps:

1. Deploy the `Hello World` webserver on CentOS with `Terraform`.
2. Configure the `Python` health check script to run periodically `every 5 seconds`.
3. Monitor the health condition using`tail -f healthcheck_webapp.log`.

Once we complete the `demo`, all remote objects managed by our `Terraform` configuration will be deleted:
```
terraform destroy
```

# Deploying the Webserver using Terraform module version of the code

The `Terraform` code with reusable `module` is placed under `tf-web-azure-module` directory.

To build and deploy this demo project using the `Terraform` module version of the code, we will carry out the steps exactly same way we have done above, but for this instance the commands will be executed within the `tf-web-azure-module` directory.

![image](https://user-images.githubusercontent.com/2681229/165856746-bd0140c1-3673-4e29-8153-4b650961e142.png)

#Module Usage
https://github.com/proarhant/terraform-webserver-azure/blob/9c554dd1318004fc3993f89c0b7b77c619378e10/tf-web-azure-module/main.tf#L3
