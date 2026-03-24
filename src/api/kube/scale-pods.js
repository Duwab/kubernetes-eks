const k8s = require('@kubernetes/client-node');

// Charger la configuration du cluster (par défaut ~/.kube/config ou dans le pod si utilisé depuis Kubernetes)
const kc = new k8s.KubeConfig();
kc.loadFromDefault();

// Initialiser le client pour les APIs Kubernetes
const k8sApi = kc.makeApiClient(k8s.AppsV1Api);

// Nom du déploiement et namespace cible
const deploymentName = process.env.DEPLOYMENT || 'deployment-demo-2';
const namespace = process.env.NAMESPACE || 'demo-2';
const replicas = process.env.REPLICAS ? parseInt(process.env.REPLICAS) : 10;

// Fonction pour mettre à jour le nombre de réplicas
async function scaleDeployment() {
  try {
    // Récupérer le déploiement existant
    const res = await k8sApi.readNamespacedDeployment(deploymentName, namespace);
    const deployment = res.body;

    // Modifier le nombre de réplicas
    deployment.spec.replicas = replicas;

    // Envoyer la mise à jour
    await k8sApi.replaceNamespacedDeployment(deploymentName, namespace, deployment);
    console.log(`Le déploiement '${deploymentName}' a été mis à jour avec ${replicas} réplicas.`);
  } catch (error) {
    console.error('Erreur lors de la mise à jour du déploiement :', error.body || error);
  }
}

// Appeler la fonction
scaleDeployment();
