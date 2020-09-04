kubectl create namespace seldon
kubectl label namespace seldon serving.kubeflow.org/inferenceservice=enabled
kubectl create -f seldon.yaml
kubectl get all -n seldon
echo "kubectl expose deployment test-deployment-example-de240ba --type=NodePort --port=8000 -n seldon"
