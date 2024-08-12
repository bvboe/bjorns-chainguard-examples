#!/bin/bash

ISTIO_PILOT="cgr.dev/chainguard/istio-pilot:latest"
ISTIO_PROXY="cgr.dev/chainguard/istio-proxy:latest"

echo Setup Istio on kind using the following images:
echo Pilot: ${ISTIO_PILOT}
echo Proxy: ${ISTIO_PROXY}

# Function to check if all pods are running
check_pods() {
  namespace=$1
  all_running=true
  not_running_pods=$(kubectl get pods -n "$namespace" --no-headers | awk '{print $3}' | grep -vE '^Running$|^Completed$')
  
  if [ -n "$not_running_pods" ]; then
    all_running=false
  fi
  
  echo $all_running
}

# Wait until all pods are running
wait_for_pods() {
  namespace=$1
  echo "Waiting for all pods in namespace '$namespace' to be in Running or Completed state..."

  while [ "$(check_pods $namespace)" != "true" ]; do
    echo "Some pods are not running yet. Waiting..."
    sleep 5
  done

  echo "All pods in namespace '$namespace' are running or completed!"
}

kind create cluster

docker pull ${ISTIO_PILOT}
docker save ${ISTIO_PILOT} -o tmp.tar
kind load image-archive tmp.tar
docker pull ${ISTIO_PROXY}
docker save ${ISTIO_PROXY} -o tmp.tar
kind load image-archive tmp.tar

rm tmp.tar

helm install istio-base istio/base -n istio-system --set defaultRevision=default --wait --create-namespace
helm install istiod istio/istiod -n istio-system \
  --set image=${ISTIO_PILOT} \
  --set pilot.image=${ISTIO_PILOT} \
  --set global.proxy_init.image=${ISTIO_PROXY} \
  --set global.proxy.image=${ISTIO_PROXY} \
  --wait

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.1.0" | kubectl apply -f -; }
sleep 1

kubectl label namespace default istio-injection=enabled
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/bookinfo/platform/kube/bookinfo.yaml
sleep 5
wait_for_pods "default"

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/bookinfo/gateway-api/bookinfo-gateway.yaml
sleep 5
kubectl annotate gateway bookinfo-gateway networking.istio.io/service-type=ClusterIP --namespace=default
sleep 5
echo Run kubectl port-forward svc/bookinfo-gateway-istio 8080:80
echo Open browser at http://localhost:8080/productpage to test