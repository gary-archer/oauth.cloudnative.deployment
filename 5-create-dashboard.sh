##################################################################
# Kubernetes dashboard setup, so that we can visualize the cluster
##################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy the dashboard
#
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
if [ $? -ne 0 ];
then
  echo 'Problem encountered deploying dashboard resources'
  exit 1
fi

#
# Wait for it to come up
#
#echo "Waiting for the Kubernetes dashboard to come up ..."
#while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$DASHBOARD_URL")" != "200" ]; do
#  sleep 2
#done

#
# Deploy user level details and get a token with which to access the dashboard
#
kubectl apply -f dashboard

#
# Get a token
#
SECRET_NAME=$(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}")
TOKEN=$(kubectl -n kubernetes-dashboard get secret $SECRET_NAME -o go-template="{{.data.token | base64decode}}")
echo $TOKEN

#
# Expose the dashboard to the host computer
#
kubectl proxy --port=8000

#
# Open the browser
#
DASHBOARD_URL='http://localhost:8000/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'
