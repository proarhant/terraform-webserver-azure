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
![image](https://user-images.githubusercontent.com/2681229/165948929-2ceba7a8-e2c5-4cb8-a0ca-179fb9d26a3d.png)

Now, execute the deployment script within the `tf-web-azure-module` directory
```
chmod +x WebserverDeployAndHealthcheck.sh
./WebserverDeployAndHealthcheck.sh
```
![image](https://user-images.githubusercontent.com/2681229/165949199-aeb12c5b-389a-492a-9f6c-e2aa615d17ad.png)

# Module Usage
https://github.com/proarhant/terraform-webserver-azure/blob/9c554dd1318004fc3993f89c0b7b77c619378e10/tf-web-azure-module/main.tf#L3-L14
