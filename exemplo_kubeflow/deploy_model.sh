git clone https://github.com/kubeflow/examples serve/
cd serve/github_issue_summarization/notebooks
 
docker run --name fiap_deploy_modelo -v $(pwd):/my_model seldonio/core-python-wrapper:0.7 /my_model IssueSummarization 0.1 gcr.io --base-image=python:3.6 --image-name=gcr-repository-name/issue-summarization
cd build/

# fix directory permission 
sudo chown `id -u` .
#NAMESPACE=kubeflow
NAMESPACE=fiap
PODNAME=`kubectl get pods --namespace=${NAMESPACE} --selector="app=jupyterhub" --output=template --template="{{with index .items 0}}{{.metadata.name}}{{end}}"`
kubectl --namespace=${NAMESPACE} cp ${PODNAME}:/home/jovyan/examples/github_issue_summarization/notebooks/seq2seq_model_tutorial.h5 .
kubectl --namespace=${NAMESPACE} cp ${PODNAME}:/home/jovyan/examples/github_issue_summarization/notebooks/body_pp.dpkl .
kubectl --namespace=${NAMESPACE} cp ${PODNAME}:/home/jovyan/examples/github_issue_summarization/notebooks/title_pp.dpkl .
 
