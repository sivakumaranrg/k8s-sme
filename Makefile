NS ?= lab

apply:
	kubectl create ns $(NS) 2>/dev/null || true
	kubectl config set-context --current --namespace=$(NS)
	kubectl apply -f config/
	kubectl apply -f deploy/deploy-web.yaml
	kubectl apply -f deploy/svc-web.yaml
	kubectl rollout status deploy/web

nodeport:
	kubectl delete svc web || true
	kubectl apply -f deploy/svc-web-nodeport.yaml

storage:
	kubectl apply -f storage/pv-web.yaml
	kubectl apply -f storage/pvc.yaml
	kubectl apply -f storage/pod-with-pvc.yaml
	kubectl wait --for=condition=Ready pod/pvc-tester --timeout=120s
