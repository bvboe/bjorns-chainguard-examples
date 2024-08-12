# Istio on kind (Kubernetes IN Docker)

This repository shows the difference between running Istio on Kubernetes using default configuration, 
and using images from Chainguard. The example is using Kind so that it can be run on a developer desktop.

See https://kind.sigs.k8s.io/ for more information about getting Kind installed.

## Deployment using default images from Istio
Deploy Kubernetes cluster, istio and sample application using [default-helm-create.sh](default-helm-create.sh).
```
$ ./default-helm-create.sh
Creating cluster "kind" ...
...
...
...
Run kubectl port-forward svc/bookinfo-gateway-istio 8080:80
Open browser at http://localhost:8080/productpage to test
```
Use `kubectl` to see all pods running
```
$ kubectl get pods -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
default              bookinfo-gateway-istio-6cdd55dbc-gpw9x       1/1     Running   0          58s
default              details-v1-64bcb758dc-k2d86                  2/2     Running   0          89s
default              productpage-v1-78787b7cdd-2n5w5              2/2     Running   0          88s
default              ratings-v1-86bdf4c6c-ndzch                   2/2     Running   0          89s
default              reviews-v1-867dd8b5b9-qwd69                  2/2     Running   0          89s
default              reviews-v2-b4c897c97-f6lb9                   2/2     Running   0          89s
default              reviews-v3-76f7b975d5-9xb8w                  2/2     Running   0          89s
istio-system         istiod-d56968787-982fx                       1/1     Running   0          98s
kube-system          coredns-7db6d8ff4d-hfvdj                     1/1     Running   0          98s
kube-system          coredns-7db6d8ff4d-wc8zb                     1/1     Running   0          98s
kube-system          etcd-kind-control-plane                      1/1     Running   0          114s
kube-system          kindnet-zvdbs                                1/1     Running   0          99s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          114s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          114s
kube-system          kube-proxy-rgqmf                             1/1     Running   0          99s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          114s
local-path-storage   local-path-provisioner-988d74bc-zvzn7        1/1     Running   0          98s
```
Digging a little deeper, you'll see that Istio is relying on the following two containers to support this configuration:
* docker.io/istio/proxyv2:1.22.3
* docker.io/istio/pilot:1.22.3

A quick scan will show that these images have a number of vulnerabilities:
```
$ grype docker.io/istio/proxyv2:1.22.3
 ✔ Vulnerability DB                [no update available]
 ✔ Pulled image
 ✔ Parsed image
 ✔ Cataloged contents
   ├── ✔ Packages                        [268 packages]
   ├── ✔ File digests                    [2,567 files]
   ├── ✔ File metadata                   [2,567 locations]
   └── ✔ Executables                     [968 executables]
 ✔ Scanned for vulnerabilities     [68 vulnerability matches]
   ├── by severity: 1 critical, 0 high, 19 medium, 41 low, 7 negligible
   └── by status:   19 fixed, 49 not-fixed, 0 ignored

$ grype docker.io/istio/pilot:1.22.3
 ✔ Vulnerability DB                [no update available]
 ✔ Pulled image
 ✔ Parsed image
 ✔ Cataloged contents
   ├── ✔ Packages                        [293 packages]
   ├── ✔ File digests                    [2,567 files]
   ├── ✔ File metadata                   [2,567 locations]
   └── ✔ Executables                     [967 executables]
 ✔ Scanned for vulnerabilities     [68 vulnerability matches]
   ├── by severity: 1 critical, 0 high, 19 medium, 41 low, 7 negligible
   └── by status:   19 fixed, 49 not-fixed, 0 ignored
```
To clean up, just delete the Kubernetes cluster.
```
$ kind delete cluster
Deleting cluster "kind" ...
Deleted nodes: ["kind-control-plane"]
```

## Deployment using images from Chainguard
Deploy Kubernetes cluster, istio and sample application using [chainguard-helm-create.sh](chainguard-helm-create.sh). Modify the following lines in the script to specify exactly what Chainguard images to use:
```
ISTIO_PILOT="cgr.dev/chainguard/istio-pilot:latest"
ISTIO_PROXY="cgr.dev/chainguard/istio-proxy:latest"
```

Run the script to get the example up and running:
```
$ ././chainguard-helm-create.sh
Setup Istio on kind using the following images:
Pilot: cgr.dev/chainguard/istio-pilot:latest
Proxy: cgr.dev/chainguard/istio-proxy:latest
Creating cluster "kind"
...
...
...
...
Run kubectl port-forward svc/bookinfo-gateway-istio 8080:80
Open browser at http://localhost:8080/productpage to test
```
Use `kubectl` to see all pods running:
```
$ kubectl get po -A                                           BjoBjornsCrdLaptop.localdomain: Mon Aug 12 17:29:03 2024

NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
default              bookinfo-gateway-istio-7d7b77c678-kj8jm      1/1     Running   0          2m
default              details-v1-64bcb758dc-qvdpq                  2/2     Running   0          2m36s
default              productpage-v1-78787b7cdd-qsftz              2/2     Running   0          2m36s
default              ratings-v1-86bdf4c6c-97jl8                   2/2     Running   0          2m36s
default              reviews-v1-867dd8b5b9-sg456                  2/2     Running   0          2m36s
default              reviews-v2-b4c897c97-lftfn                   2/2     Running   0          2m36s
default              reviews-v3-76f7b975d5-v58zj                  2/2     Running   0          2m36s
istio-system         istiod-66646d4864-tklvm                      1/1     Running   0          2m46s
kube-system          coredns-7db6d8ff4d-7rtnt                     1/1     Running   0          2m46s
kube-system          coredns-7db6d8ff4d-bsdg2                     1/1     Running   0          2m46s
kube-system          etcd-kind-control-plane                      1/1     Running   0          3m1s
kube-system          kindnet-6z6lx                                1/1     Running   0          2m46s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          3m1s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          3m1s
kube-system          kube-proxy-zjjjh                             1/1     Running   0          2m46s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          3m1s
local-path-storage   local-path-provisioner-988d74bc-rhhxr        1/1     Running   0          2m46s
```
Digging a little deeper using 'kubectl describe pod', you'can verify that Istio indeed is using the following two images from Chainguard to run:
* cgr.dev/chainguard/istio-proxy:latest
* cgr.dev/chainguard/istio-pilot:latest

A quick scan will show that these images have zero vulnerabilities and about half the number of OS packages installed:
```
$ grype cgr.dev/chainguard/istio-proxy:latest
 ✔ Vulnerability DB                [no update available]
 ✔ Loaded image
 ✔ Parsed image
 ✔ Cataloged contents
   ├── ✔ Packages                        [133 packages]
   ├── ✔ File digests                    [203 files]
   ├── ✔ File metadata                   [203 locations]
   └── ✔ Executables                     [146 executables]
 ✔ Scanned for vulnerabilities     [0 vulnerability matches]
   ├── by severity: 0 critical, 0 high, 0 medium, 0 low, 0 negligible
   └── by status:   0 fixed, 0 not-fixed, 0 ignored

$ grype cgr.dev/chainguard/istio-pilot:latest
 ✔ Vulnerability DB                [no update available]
 ✔ Loaded image
 ✔ Parsed image
 ✔ Cataloged contents
   ├── ✔ Packages                        [147 packages]
   ├── ✔ File digests                    [22 files]
   ├── ✔ File metadata                   [22 locations]
   └── ✔ Executables                     [1 executables]
 ✔ Scanned for vulnerabilities     [0 vulnerability matches]
   ├── by severity: 0 critical, 0 high, 0 medium, 0 low, 0 negligible
   └── by status:   0 fixed, 0 not-fixed, 0 ignored
```
