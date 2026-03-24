# Auto scaling

Dans les deux rubriques suivantes :

* **Gestion des droits :** Finalement assez approximatif, c'est assez complexe de gérer finement tous les droits nécessaires. Je crois que je m'étais contenté du `AutoScalingFullAccess`
* **`aws autoscaling` :** Utilisé et fonctionne


## About EKS Auto Mode

Depuis la console > EKS > Overview, il y a une option _EKS Auto Mode_.

Cette option permet de configurer l'auto-scaling automatiquement sur le cluster, mais "brut" (sans choisir les machines types de machines ou Node Groups).

Elle est pratique pour démarrer, mais pas forcément pertinente pour de la prod.

## Gestion des droits

Ajouter ces policies à l'auto-scaling group

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
```

Pour tricher, on peut mettre AutoScalingFullAccess

Ou alors ça fonctionne si on le met dans cluster config (cf [eksctl schema](https://eksctl.io/usage/schema))

Egalement activer EKS Auto Mode via la console.

Ajouter à eksctl-$CLUSTER_NAME-cluster-ServiceRole-7QS5IRmbtkBk les règles

AmazonEKSBlockStoragePolicy
AmazonEKSComputePolicy
AmazonEKSLoadBalancingPolicy
AmazonEKSNetworkingPolicy

https://docs.aws.amazon.com/eks/latest/userguide/automode-get-started-eksctl.html


Création d'un seul role IAM sur le compte AWS pour l'administration d'un cluster EKS

* AmazonEKSBlockStoragePolicy
* AmazonEKSClusterPolicy
* AmazonEKSComputePolicy
* AmazonEKSLoadBalancingPolicy
* AmazonEKSNetworkingPolicy
* AmazonEKSVPCResourceController


Cluster role missing recommended managed policies
The cluster role must have the following managed policies or equivalent permissions to use EKS Auto Mode:
AmazonEKSBlockStoragePolicy
AmazonEKSComputePolicy
AmazonEKSLoadBalancingPolicy
AmazonEKSNetworkingPolicy


## Lancement de l'auto-scaler

```shell
helm repo add autoscaler https://kubernetes.github.io/autoscaler

# KO Method 1 - Using Autodiscovery
# helm install aws-eks-autscaler autoscaler/cluster-autoscaler \
#     --set 'autoDiscovery.clusterName'=$CLUSTER_NAME

# TODO: find a way to
#   * automatically add policies
#   * find auto-scaling group name

# Method 2 - Specifying groups manually
# export NODE_GROUP_MNG_ASG_NAME="eks-eks-mng-cec9dafe-6972-b52e-3e93-bd6e75c7ea03"
export NODE_GROUP_ASG_NAME_1=$(aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?Tags[?Key=='eks:nodegroup-name' && Value=='eks-grp-1']].AutoScalingGroupName | [0]" \
  --output text)
export NODE_GROUP_ASG_NAME_2=$(aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?Tags[?Key=='eks:nodegroup-name' && Value=='eks-grp-2']].AutoScalingGroupName | [0]" \
  --output text)

# https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
helm install aws-eks-autoscaler autoscaler/cluster-autoscaler \
    --namespace kube-system \
    --set "autoscalingGroups[0].name=$NODE_GROUP_ASG_NAME_1" \
    --set "autoscalingGroups[0].maxSize=5" \
    --set "autoscalingGroups[0].minSize=0" \
    --set "autoscalingGroups[1].name=$NODE_GROUP_ASG_NAME_2" \
    --set "autoscalingGroups[1].maxSize=5" \
    --set "autoscalingGroups[1].minSize=0" \
    --set nodeSelector."grp-role"=management \
    --set "extraArgs.scale-down-delay-after-add=1m" \
    --set "extraArgs.scale-down-unneeded-time=1m" \
    --set awsRegion=$AWS_REGION

# kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=...
./helpers/show-node-groups.sh
./helpers/logs-autoscaler.sh

helm upgrade/uninstall aws-eks-autoscaler
```
