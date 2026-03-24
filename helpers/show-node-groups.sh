#!/bin/bash
echo -e "POD\tNODE\tNODEGROUP"
kubectl get pods -o wide -n default | tail -n +2 | while read line; do
  pod=$(echo $line | awk '{print $1}')
  node=$(echo $line | awk '{print $7}')
  nodegroup=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.eks\.amazonaws\.com/nodegroup}')
  echo -e "$pod\t$node\t$nodegroup"
done
kubectl get pods -o wide -n demo | tail -n +2 | while read line; do
  pod=$(echo $line | awk '{print $1}')
  node=$(echo $line | awk '{print $7}')
  nodegroup=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.eks\.amazonaws\.com/nodegroup}')
  echo -e "$pod\t$node\t$nodegroup"
done
kubectl get pods -o wide -n demo-2 | tail -n +2 | while read line; do
  pod=$(echo $line | awk '{print $1}')
  node=$(echo $line | awk '{print $7}')
  nodegroup=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.eks\.amazonaws\.com/nodegroup}')
  echo -e "$pod\t$node\t$nodegroup"
done
kubectl get pods -o wide -n kube-system | tail -n +2 | while read line; do
  pod=$(echo $line | awk '{print $1}')
  node=$(echo $line | awk '{print $7}')
  nodegroup=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.eks\.amazonaws\.com/nodegroup}')
  echo -e "$pod\t$node\t$nodegroup"
done
