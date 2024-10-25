# Create a Kind cluster
kind create cluster

# Install cert-manager
```
helm repo add jetstack https://charts.jetstack.io
helm install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.16.1 \
        --set crds.enabled=true
```


# Install Metal LB
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

GW_IP=$(docker network inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' kind)
NET_IP=$(echo ${GW_IP} | sed -E 's|^([0-9]+\.[0-9]+)\..*$|\1|g')
```

```
cat <<EOF | sed -E "s|172.19|${NET_IP}|g" | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.19.255.200-172.19.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF
```


# Install Kamaji
```
helm repo add clastix https://clastix.github.io/charts
helm upgrade --install kamaji clastix/kamaji --namespace kamaji-system --create-namespace --set 'resources=null'
```


# Create a Tenant Control Plane
```
kubectl apply -f https://raw.githubusercontent.com/clastix/kamaji/master/config/samples/kamaji_v1alpha1_tenantcontrolplane.yaml
```