
helm repo add cetic https://cetic.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add dysnix https://dysnix.github.io/charts/
helm repo update

helm install -f values.yaml nifi-sisyphus cetic/nifi
zarf init --storage-class "aws-pg-sc"