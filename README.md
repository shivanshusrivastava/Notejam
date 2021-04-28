# Notejam
NoteJam project
NodeJS application is used for the demo, application is to be deployed in Docker container and Kubernetes is used for container orchestration. 
A powershell script Main.ps1 is added which provision the resources in cloud. The script includes Azure CLI commands and requires azure cli along with aks-preview extension installed on the machine where it is required to be executed.
Script performs below tasks:
1.	Create Resource group in an Azure Subscription
2.	Create Storage account and add a fileshare for persistent volume
3.	Create a Virtual network and subnet which will be assigned to Azure Kubernetes Services cluster
4.	Create an AKS cluster with node count 1 having VM Size =Standard_DS2_v2, assigned subnet which was created in point 3.
5.	Create secret to connect to docker hub & azure storage account.
6.	Save AKS credential locally.
7.	Build Docker container for Notejam application
8.	Push docker image to docker hub repository
9.	Deploy Nginx ingress in AKS
10.	Deploy Helm Chart to AKS Cluster. Chart contains below resources:

*	Persistent Volume from Azure file share storage
*	Persistent Volume claim to be mounted on POD. Sqllite db will be generated on this mounted volume. The volume will be available across all pods.
* Config Map for db configuration
* Deployments to create pods with PVC mounted as volume and config maps as environment variables
* HPA-Horizontal pod Scalar which monitors the performance of pods and create new pods after target limit is reached
* Cluster IP Service to redirect the traffic to available pods
* Ingress to redirect traffic to various services. 

To run the application, hostname notejam.web.local should be passed to ingress via browser, hence a hostfile entry is required for notejam.web.local which should point to external ip of ingress.
