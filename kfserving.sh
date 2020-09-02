# sudo minikube start --vm-driver=none --kubernetes-version=v1.17.11
git clone https://github.com/kubeflow/kfserving.git
cd kfserving && ./hack/quick_install.sh
export INGRESS_HOST=$(curl -s checkip.amazonaws.com)
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
