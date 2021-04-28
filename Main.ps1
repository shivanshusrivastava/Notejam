$rg="notejam"
$vnet="notejam_vnet"
$cluster="notejam-aks"
$subscription="54a55a45-a096-4efc-8ffa-e9ba116103bc"
$storage_account_name="notejamstorage"
$location="northeurope"
$share_name="notejam-share"
az login
az account set -s $subscription
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.Compute
az provider register -n Microsoft.Network
az provider register -n Microsoft.Storage
az provider list -o table
az group create --name $rg --location $location 
#az group delete --name $rg 
#Create storage account 
# Create a storage account
az storage account create -n $storage_account_name -g $rg -l $location --sku Standard_LRS

# Export the connection string as an environment variable, this is used when creating the Azure file share
$AZURE_STORAGE_CONNECTION_STRING=az storage account show-connection-string -n $storage_account_name -g $rg -o tsv
Write-Output $AZURE_STORAGE_CONNECTION_STRING
# Create the file share
az storage share create -n $share_name --connection-string $AZURE_STORAGE_CONNECTION_STRING
$storage_key=$(az storage account keys list --resource-group $rg --account-name $storage_account_name --query "[0].value" -o tsv)

# Echo storage account name and key
Write-Output Storage account name: $storage_account_name
Write-Output Storage account key: $storage_key

# Create our two subnet network 
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet --name nodesubnet --address-prefixes 10.2.0.0/16 -o none 
#az network vnet subnet create -g $rg --vnet-name $vnet --name podsubnet --address-prefixes 10.3.0.0/16 -o none 

az aks create --resource-group $rg --name $cluster --node-count 1 --generate-ssh-keys `
--kubernetes-version 1.20.5 --node-vm-size=Standard_DS2_v2 --network-plugin azure --vnet-subnet-id /subscriptions/$subscription/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/nodesubnet `
--docker-bridge-address 172.17.0.1/16 --dns-service-ip 10.0.0.10  --service-cidr 10.0.0.0/16
#  --pod-subnet-id  /subscriptions/$subscription/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet/subnets/podsubnet

az aks get-credentials --resource-group $rg --name $cluster
kubectl get nodes | Write-Output
kubectl cluster-info | Write-Output
kubectl create secret generic regcred --from-file=.dockerconfigjson=C:/Users/shivanshu/.docker/config.json --type=kubernetes.io/dockerconfigjson
kubectl create secret generic fileshare-secret --from-literal=azurestorageaccountname=$storage_account_name --from-literal=azurestorageaccountkey=$storage_key

#Setup Ingress controller
# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress ingress-nginx/ingress-nginx `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

cd C:\Users\shivanshu\source\repos\Notejam\notejam\express\notejam
docker login
docker build . --tag shivanshusrivastava/notejam:latest
docker push shivanshusrivastava/notejam:latest
helm install  notejam notejam

#kubectl  get services -o wide -w nginx-ingress-ingress-nginx-controller
#kubectl exec --stdin --tty notejam-6fd7d95df7-tpgf9 -- /bin/sh