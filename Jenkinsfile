pipeline {
   agent any
    options {
        timeout(time: 1, unit: 'HOURS')
    }


    stages {

        stage('Docker') {
            steps {
           
                sh '''#!/bin/bash -x
                    set -e
                    GIT_BRANCH=$(echo $GIT_BRANCH| awk -F "/" '{ print $2 }')
                    echo "BRANCH IS $GIT_BRANCH"
                    if [[ $GIT_BRANCH =~ prod-.*[0-9].*[0-9].*[0-9] ]] || [[ $GIT_BRANCH =~ stag-.*[0-9].*[0-9].*[0-9] ]]
                    then
                    export IMAGE_TAG=$GIT_BRANCH && echo "$IMAGE_TAG" > imagetag
                    elif [[ $GIT_BRANCH == 'master' ]] || [[ $GIT_BRANCH == 'main' ]]
                    then 
                    export IMAGE_TAG="$BUILD_ID-rc"
                    elif [[ $GIT_BRANCH == 'develop' ]]; then export IMAGE_TAG="$BUILD_ID-dev"
                    elif [[ $GIT_BRANCH =~ feature-.* ]] || [[ $GIT_BRANCH =~ hotfix-.* ]]
                    then
                       IMAGE_TAG=$GIT_BRANCH-$BUILD_ID && echo "$IMAGE_TAG" > imagetag
                    else
                    echo "Valid git branches for deployment- master, main, develop, feature-*, hotfix-* and :::: tags of prod-.*[0-9].*[0-9].*[0-9],stag-.*[0-9].*[0-9].*[0-9]"
                    exit 1
                    fi

                    echo "dockerbuild"
                    sudo docker build -t $IMAGE_NAME:$IMAGE_TAG .

                    echo "image push"
                    sudo aws ecr get-login-password --region eu-central-1 | sudo docker login --username AWS --password-stdin ${ECR_ACCOUNT}
                    sudo docker push $IMAGE_NAME:$IMAGE_TAG

                '''
                script {
                // trim removes leading and trailing whitespace from the string
                IMAGE_TAG = readFile('imagetag').trim()
                }
                echo "${IMAGE_TAG}" // prints 'hotness'
            }
        }
        stage('Helm') {
            
            steps {
                script {
                    if (env.BRANCH_NAME =~ feature-*) {
                       echo "${IMAGE_TAG}" 
                       sh "echo image tag is $IMAGE_TAG"   
                    } else {
                        echo 'I execute elsewhere'
                    }
                }

                    
            }
        }

//         stage('Deploy') {
//             steps {
//                 sh '''
//                     set -e
//                     if [ ${BRANCH_NAME} == develop ]; then
//                          helm repo update
//                          kubectl config use-context trainer-stg
//                          helm tiller run helm upgrade --install keycloak --recreate-pods omnius-stg/keycloak --version $VERSION-${BRANCH_NAME}-${BUILD_NUMBER} --set CUSTOMERNAME=omnius --set ENV=stg --set image.onpremiserepository=packages-stg.internal.omnius.com/omnius --namespace keycloak
//                     fi
//                     if [ ${CHANGE_BRANCH:0:8} == feature/ ] && [ ${CHANGE_TARGET} == develop ]; then
//                         helm repo update
//                         kubectl config use-context trainer-pr-1
//                         helm tiller run helm upgrade --install keycloak --recreate-pods omnius-pr/keycloak --version $TAG --set CUSTOMERNAME=omnius --set ENV=pr --set image.onpremiserepository=packages-pr.internal.omnius.com/omnius --namespace keycloak
//                     fi
// if [ ${CHANGE_TARGET:0:8} == support/ ] && [ ${CHANGE_BRANCH:0:8} == feature/ ]; then
//                           echo "No deployment"
// fi
//                 '''
//             }
//         }
    }
    post {
        always {
          deleteDir()
        }
    }
}
