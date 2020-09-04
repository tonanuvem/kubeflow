kubectl create namespace seldon
kubectl label namespace seldon serving.kubeflow.org/inferenceservice=enabled
kubectl create -f seldon.yaml
kubectl get all -n seldon
echo "kubectl expose deployment $(kubectl get deploy -n seldon -o jsonpath='{.items[0].metadata.name}') --name modelo --type=NodePort --port=8000 -n seldon"
#kubectl create service nodeport modelo --node-port 31000 --tcp=8000:8000 -n seldon
export HOST=$(curl -s checkip.amazonaws.com)
export SVC_PORT=$(kubectl -n seldon get service modelo -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
echo "Acessar: http://$HOST:$SVC_PORT"
#curl -X POST http://$HOST:$SVC_PORT/seldon/seldon/iris-model/api/v1.0/predictions \
echo "curl -X POST http://$HOST:$SVC_PORT/api/v1.0/predictions -H 'Content-Type: application/json' -d '{ "data": { "ndarray": [[1,2,3,4]] } }'"
print
curl -X POST http://$HOST:$SVC_PORT/api/v1.0/predictions \
    -H 'Content-Type: application/json' \
    -d '{ "data": { "ndarray": [[1,2,3,4]] } }'
