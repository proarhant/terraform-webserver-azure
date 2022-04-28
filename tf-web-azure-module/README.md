#  Deploy the Webserver using Terraform module version of the code
The `Terraform` code with reusable `module` is placed under `tf-web-azure-module` directory.

To build and deploy this demo project using the `Terraform` module version of the code, we will execute the commands within the `tf-web-azure-module` directory.

Please run the following commands on `Linux` enviromnent to test the deployment of a sample `Hello World` webserver.

```
# This demo has been executed and tested on Terraform v1.1.8 and Python 3.7.3 on Linux (Azure Cloud Shell)
terraform -version
python --version

# Download the code repo
git clone https://github.com/proarhant/terraform-webserver-azure.git && cd terraform-webserver-azure

# Change to the dir containing the module version of the code
cd tf-web-azure-module

# Generate SSH key pair for this demo deployment...
ssh-keygen -P "" -t rsa -C "This SSH kay pair is for demo purpose only" -f ./id_rsa_tfadmin
```

![image](https://user-images.githubusercontent.com/2681229/165859873-f0e4b3dc-f519-4452-af43-b13f3c67cc4f.png)

Now, execute the deployment script within the `tf-web-azure-module` directory

```
chmod +x WebserverDeployAndHealthcheck.sh
./WebserverDeployAndHealthcheck.sh
```
![image](https://user-images.githubusercontent.com/2681229/165860212-5d76834f-8e4b-442a-b7af-a8c5d71c1b19.png)

# Module Usage
https://github.com/proarhant/terraform-webserver-azure/blob/9c554dd1318004fc3993f89c0b7b77c619378e10/tf-web-azure-module/main.tf#L3-L14
