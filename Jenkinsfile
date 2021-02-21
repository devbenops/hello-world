pipeline {
   agent any
    options {
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
     GIT_BRANCH_NAME = "${GIT_BRANCH.split("/")[1]}"
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
        stage('Helm-staging') {
            when {
                      expression { env.GIT_BRANCH_NAME == "feature-hello-world" }
                }
            
            steps {
                script {
                    if (env.GIT_BRANCH_NAME == "feature-hello-world" ) {
                       echo "${IMAGE_TAG}" 
                       sh "echo image tag is $IMAGE_TAG" 
                       sh "kubectl config use-context ${STAGING_CLUSTER}"
                       sh "cd devops/helm/$HELM_CHART_NAME && helm upgrade -f values-stag.yaml ${HELM_CHART_NAME} . --install  --set image.Imagetag=$IMAGE_TAG --namespace default --wait --timeout ${HELM_TIMEOUT}"
                    } 
                }
                    
            }
        }

        stage('Approval') {
                when {
                      expression { env.GIT_BRANCH_NAME == "master" }
                }

                steps {
                    script {
                        def userInput = input(id: 'confirm', message: 'Deploy production?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Production Deployment', name: 'confirm'] ])
                    }
                }
        }

        stage('Helm-prod') {
            when {
                      expression { env.GIT_BRANCH_NAME == "master" }
                }
            
            steps {
                script {
                    if (env.GIT_BRANCH_NAME == "master" ) {
                       echo "${IMAGE_TAG}" 
                       sh "echo image tag is $IMAGE_TAG" 
                       sh "kubectl config use-context ${PROD_CLUSTER}"
                       sh "cd devops/helm/$HELM_CHART_NAME && helm upgrade -f values-prod.yaml ${HELM_CHART_NAME} . --install  --set image.Imagetag=$IMAGE_TAG --namespace default --wait --timeout ${HELM_TIMEOUT}"
                    } 
                }
                    
            }
        }

    }
    post {
        always {
          deleteDir()
        }
    }
}
