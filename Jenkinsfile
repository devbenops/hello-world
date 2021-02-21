node {


    def dockerBuild = '''#!/bin/bash -x
set -e
echo "dockerbuild"
docker build -t $IMAGENAME:$GIT_BRANCH .
'''

    def imagePush = '''#!/bin/bash -x
set -e
echo "image push"
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 501875964238.dkr.ecr.eu-central-1.amazonaws.com
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

//     def findReplaceTag = '''#!/bin/bash -x
// set -e
// pushd /var/lib/jenkins/workspace/$HELM_REPO_NAME

// for i in {0..6};do
//  if [[ $HELM_COMPONENT == $(yq r $HELM_MAIN_CHART_NAME/requirements.yaml dependencies[$i].name) ]]; then
//     yq w -i $HELM_MAIN_CHART_NAME/requirements.yaml dependencies[$i].version $gitlabTag
//  fi
// done

// yq w -i values.yaml $HELM_TAG_LOCATION $gitlabTag
// yq w -i Charts.yaml version $gitlabTag
// if [[ $(git diff --name-only | grep $HELM_COMPONENT | wc -l) == 3 ]]
// then
//     for fl in `git diff --name-only`; do
//         if [[ $fl == "$HELM_COMPONENT/values.yaml" || $fl == "$HELM_COMPONENT/Charts.yaml" || $fl == "$HELM_MAIN_CHART_NAME/requirements.yaml" ]]; then
//             echo "Changes are only in $fl";
//         else
//             echo "Following files are changed"
//             git diff --name-only
//             exit 1;
//         fi
//     done
// else
//     echo "Following files are changed"
//     git diff --name-only
//     exit 1;
// fi

// git add .
// git commit -m "adding new tag $gitlabTag"
// git push origin $HELM_WORKING_BRANCH
// git tag $gitlabTag
// git push origin $gitlabTag
// popd
// '''
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
    env.HELM_REPO_NAME = project_parms[1]
    env.HELM_WORKING_BRANCH = project_parms[2]
    env.HELM_MAIN_CHART_NAME = project_parms[3]
    env.HELM_COMPONENT = project_parms[4]
    env.HELM_VALUES_FILE_NAME = project_parms[5]
    env.KUBERNETES_CONFIGFILE_LOCATION = project_parms[6]
    env.RUNDECK_KUBERNETES_CONFIGFILE = project_parms[7]
    env.RUNDECK_SERVER_LOGIN = project_parms[8]
    env.HELM_TAG_LOCATION = project_parms[9]


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
            stage 'Changing directory to edit manifest file'
                sh "$changeDir"
            stage 'Find and replace tag'
                sh "$findReplaceTag"
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
        }

    } else {
        println("Tag should be in the format (stag|prod)-[a-zA-Z]{2,}-x.x.x")
    }

}
