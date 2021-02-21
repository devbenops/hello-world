node {


    def dockerBuild = '''#!/bin/bash -x
set -e
echo "dockerbuild"
docker build -t $IMAGENAME:$GIT_BRANCH .
'''

    def imagePush = '''#!/bin/bash -x
set -e
echo "image push"
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${ECR_ACCOUNT}
sudo docker push $IMAGENAME:$GIT_BRANCH
'''
    def imageCleanUp = '''#!/bin/bash -x
set -e
echo "image cleaning"
if [ -z "$(sudo docker images ${IMAGENAME} | tail -n +12)" ]; then
   echo "No images for cleanup"
else
   sudo docker images ${IMAGENAME} | tail -n +12 | awk '{print $1 ":" $2}' | xargs docker rmi
fi
'''

    def deployment = '''#!/bin/bash -x
set -e

 
pushd /var/lib/jenkins/workspace/$HELM_REPO_NAME/helm/$HELM_REPO_NAME
if [[ $GIT_BRANCH =~ stag-.*[0-9].*[0-9].*[0-9] ]]
then 
   kubectl config use-context ${STAGING_CLUSTER}
   export VALUES_FILE=values-stag.yaml
   helm upgrade -f ${VALUES_FILE} ${RELEASE_NAME} . --install  --set image.Imagetag=$GIT_BRANCH --namespace default --wait --timeout ${HELM_TIMEOUT}

else
   kubectl config use-context $PROD_CLUSTER
   export VALUES_FILE=values-prod.yaml
   helm upgrade -f ${VALUES_FILE} ${RELEASE_NAME} . --install  --set image.Imagetag=$GIT_BRANCH --namespace default --wait --timeout ${HELM_TIMEOUT}
popd
'''

// Main program starts here

    def gitTag = env.GIT_BRANCH
    def project_parms = project_parms.split("\\r?\\n") as String[]
    env.IMAGENAME = project_parms[0]
    def ecrValues = "$IMAGENAME".split('/')
    env.ECR_ACCOUNT = ecrValues[2]
    env.HELM_REPO_NAME = project_parms[1]
    env.RELEASE_NAME = project_parms[1]
    env.STAGING_CLUSTER = project_parms[2]
    env.PROD_CLUSTER = project_parms[3]


    if  (gitTag ==~ /refs\/tags\/(stag|prod)-[a-zA-Z]{2,}-\d{1,}.\d{1,}.\d{1,}/) {
        println "Received a tag"
        println "$gitTag"
        def gitValues = "$gitTag".split('/')
        env.GIT_BRANCH = gitValues[2]
        if( gitValues[2] ==~ /stag-[a-zA-Z]{2,}-\d{1,}.\d{1,}.\d{1,}/) {
            stage 'Identifing Tag'
                checkout scm
            stage 'Docker Image build'
                sh "$dockerBuild"
            stage 'Image Push to build'
                sh "$imagePush"
            stage 'Deployment'
                sh "$deployment"
            stage 'Cleanup old images'
                sh "$imageCleanUp"
        } else if( gitValues[2] ==~ /prod-[a-zA-Z]{2,}-\d{1,}.\d{1,}.\d{1,}/) {
            stage 'Identifing Tag and checkout'
                checkout scm
            stage 'Docker Image build'
                sh "$dockerBuild"
            stage 'Image Push to build'
                sh "$imagePush"
            stage 'Cleanup old images'
                sh "$imageCleanUp"
            // stage('Prod-Approval') {
            //     steps {
            //         script {
            //             def userInput = input(id: 'confirm', message: 'Helm Deploy Production?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Helm Deploy Production', name: 'confirm'] ])
            //         }
            //     }
            // }
            stage 'Deployment'
                sh "$deployment"
        }

    } else {
        println("Tag should be in the format (stag|prod)-[a-zA-Z]{2,}-x.x.x")
    }

}
