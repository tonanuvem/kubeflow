# https://azure.github.io/kubeflow-aks/main/docs/deployment-options/vanilla-installation/
# grep -Rnw '/path/to/somewhere/' -e 'pattern'

echo "Clonando o repo: kubeflow-aks"
git clone --recurse-submodules https://github.com/Azure/kubeflow-aks.git
cd kubeflow-aks
SIGNEDINUSER=$(az ad signed-in-user show --query id --out tsv)
RGNAME=kubeflow
az group create -n $RGNAME -l eastus

# Building a complete Kubernetes operational environment is hard work! AKS Construction dramatically accelerates this work
# https://learn.microsoft.com/pt-br/azure/azure-resource-manager/bicep/overview?tabs=bicep
echo "Criando o Cluster AKS para executar o Kubeflow"
DEP=$(az deployment group create -g $RGNAME --parameters signedinuser=$SIGNEDINUSER kubernetesVersion="1.28.0" -f main.bicep -o json)

echo $DEP > kubeflow_DEP.json

# para recuperar o valor do json (comando abaixo):
# export DEP=$(cat kubeflow_DEP.json)

KVNAME=$(echo $DEP | jq -r '.properties.outputs.kvAppName.value')
AKSCLUSTER=$(echo $DEP | jq -r '.properties.outputs.aksClusterName.value')
TENANTID=$(az account show --query tenantId -o tsv)
ACRNAME=$(az acr list -g $RGNAME --query "[0].name"  -o tsv)

# Install kubelogin and log into the cluster 
az aks get-credentials --resource-group $RGNAME --name $AKSCLUSTER
kubelogin convert-kubeconfig -l azurecli

# Deploy Kubeflow without TLS using Default Password
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

cd manifests/
git checkout v1.7-branch
cd ..
cp -a deployments/vanilla manifests/vanilla
cd manifests/
while ! kustomize build vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com



echo "Pronto."
