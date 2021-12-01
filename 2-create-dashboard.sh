##################################################################
# Kubernetes dashboard setup, so that we can visualize the cluster
##################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Get the Helm chart
#
helm repo add dashboard https://kubernetes.github.io/dashboard 2>/dev/null

#
# Ensure that any old versions are removed
#
cd dashboard
kubectl delete -f kubernetes.yaml 2>/dev/null

#
# Apply the values file to start deploying resources
#
helm install dashboard dashboard/kubernetes-dashboard --values values.yaml -n deployed --create-namespace
helm template dashboard . values.yaml
if [ $? -ne 0 ];
then
  echo 'Problem encountered creating Kubernetes YAML from the Helm Chart'
  exit 1
fi
exit

#
# Access at https://127.0.0.1:8443/ using the details from this guide
# https://medium.com/@munza/local-kubernetes-with-kind-helm-dashboard-41152e4b3b3d
#
POD_NAME=$(kubectl get pods -n deployed -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=dashboard" -o jsonpath="{.items[0].metadata.name}")
kubectl -n deployed port-forward $POD_NAME 8443:8443