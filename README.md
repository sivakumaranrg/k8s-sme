
# 🚀 k8s-sme (Kubernetes SME Journey)

Hands-on Kubernetes labs built from scratch, focusing on practical DevOps scenarios — Deployments, Services, ConfigMaps, Secrets, Storage (PV/PVC), RBAC, and NetworkPolicy.

This repo is reproducible in KodeKloud or Minikube playgrounds.

## 🧠 What You’ll Learn
- Deployment rollout + ReplicaSets
- ClusterIP vs NodePort service exposure
- ConfigMap + Secret environment injection
- Readiness + Liveness probes
- Persistent volume design (PV/PVC)
- RBAC least privilege
- NetworkPolicy ingress isolation

## ⚙️ Quick Start

```bash
kubectl create ns lab 2>/dev/null || true
kubectl config set-context --current --namespace=lab
kubectl apply -f config/
kubectl apply -f deploy/deploy-web.yaml
kubectl apply -f deploy/svc-web.yaml
kubectl rollout status deploy/web
kubectl get all
```

## 🌐 NodePort Test (Day3)

```bash
kubectl delete svc web
kubectl apply -f deploy/svc-web-nodeport.yaml
NODE_PORT=$(kubectl get svc web -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -I http://$NODE_IP:$NODE_PORT
```

Expect: HTTP/1.1 200 OK

## 💾 Persistent Volume / PVC (Day4)

```bash
kubectl apply -f storage/pv-web.yaml
kubectl apply -f storage/pvc.yaml
kubectl apply -f storage/pod-with-pvc.yaml
kubectl wait --for=condition=Ready pod/pvc-tester --timeout=120s
STAMP=$(date +%s)
kubectl exec pvc-tester -- sh -c "echo $STAMP >/data/proof.txt && cat /data/proof.txt"
kubectl delete pod pvc-tester
kubectl apply -f storage/pod-with-pvc.yaml
kubectl wait --for=condition=Ready pod/pvc-tester --timeout=120s
kubectl exec pvc-tester -- sh -c "echo EXPECT:$STAMP; echo FOUND:$(cat /data/proof.txt)"
```

Expect: SAME timestamp

## 🔐 RBAC (Day5)

```bash
kubectl apply -f rbac/
kubectl auth can-i list pods --as=system:serviceaccount:lab:viewer-sa -n lab   # yes
kubectl auth can-i delete pods --as=system:serviceaccount:lab:viewer-sa -n lab # no
```

## 🧱 NetworkPolicy (Day5 Extended)

```bash
kubectl apply -f policy/deny-all.yaml
kubectl run curl --image=busybox:1.36 --restart=Never --command -- sh -c "wget -qO- http://web || echo BLOCKED"
kubectl apply -f policy/allow-web.yaml
kubectl delete pod curl
kubectl run curl --image=busybox:1.36 --restart=Never --command -- sh -c "wget -qO- http://web | head -n1"
```

## Repo Structure

```
config/     # ConfigMap + Secret
deploy/     # Deployment + Services
storage/    # PV + PVC
rbac/       # ServiceAccount + Role + RoleBinding
policy/     # deny-all + allow-web
```

## Troubleshooting

| issue | reason | fix |
|-------|--------|-----|
| immutable svc fields | svc type switched | delete svc + apply |
| PVC Pending | no storageclass or wrong PV | apply pv-web.yaml |
| CM/Secret change not applied | env baked into pod | force new rollout |

force rollout sample:
```bash
kubectl patch deploy web -p '{"spec":{"template":{"metadata":{"annotations":{"roll":"v1"}}}}}'
```

## Author
Sivakumaran RG — DevOps Engineer
```
