#!/bin/bash

POD_NAME=$(kubectl get pods \
  -o jsonpath='{.items[0].metadata.name}' \
  --namespace=kube-system \
  -l "app.kubernetes.io/name=aws-cluster-autoscaler,app.kubernetes.io/instance=aws-eks-autoscaler")

printf "autoscaler/cluster-autoscaler pod name: $POD_NAME\n"

kubectl logs -f -n kube-system $POD_NAME
