# hello-world Deployment

# application

Hello-world is a java micro service application deployed in the backend namespace.

# Tools used

1. aws EKS
2. aws ECR
3. Jenkins
4. Helm

# Deployment stratregy

We use helm as templating engine for the application deployment and Kubernetes rolling update with maxunavailable for a high availability deployment.

Also, I use the following kubernetes stratregies/methods to achieve high availablity and stability in the deployment process

    1. HorizontalPodAutoscaler
    2. PodDisruptionBudget
    3. nodeAffinity with requiredDuringSchedulingIgnoredDuringExecution based on node groups

    4. readiness probe
    5. Liveness probe

# Project structure 

            ├── Dockerfile
            ├── Jenkinsfile
            ├── README.md
            ├── devops
            │   └── helm
            │       └── hello-world
            │           ├── Chart.yaml
            │           ├── templates
            │           │   ├── _helpers.tpl
            │           │   ├── configmap.yaml
            │           │   ├── deployment.yaml
            │           │   ├── hpa.yaml
            │           │   ├── ingress.yaml
            │           │   ├── pdb.yaml
            │           │   └── service.yaml
            │           ├── values-prod.yaml
            │           └── values-stag.yaml
            └── target
                └── helloworld.jar

# CI/CD pipeline

I opted Jenkins Declarative pipeline method to achieve continous integration and deployment based on branch stratregy.

# Prerequiesites

1. An aws load balanced kubernetes cluster (EKS)
2. Atleast one node group with the labels present in the nodeaffinity secion of the deployment file
3. An ingress controller to manage ingress objects
4. A kubernetes secret having TLS objects to terminate ssl at ingress level.
5. cluster autoscaler  should be pre installed and setup.
6. A fully setup jenkins server with access control to kubernetes cluster for helm deployment
7. setup webhooks on github project to trigger the pipeline

# Binaries should be installed on jenkins server

 1. aws cli
 2. docker ce
 3. kubectl
 4. helm3

 Note// The jenkins server must have IAM role attached to perform push docker images to ECR. Also, add the role to the kubernetes cluster rbac configmap/aws-auth to access eks cluster.

