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
           
              // Fixing up docker image tag and docker build
                sh '''#!/bin/bash -x
                    set -e
                    GIT_BRANCH=$(echo $GIT_BRANCH| awk -F "/" '{ print $2 }') 
                    if [[ $GIT_BRANCH == 'master' ]] || [[ $GIT_BRANCH == 'main' ]];then
                        export IMAGE_TAG="$BUILD_ID-rc" && echo "$IMAGE_TAG" > imagetag
                    elif [[ $GIT_BRANCH == 'develop' ]]; then 
                        export IMAGE_TAG="$BUILD_ID-dev" && echo "$IMAGE_TAG" > imagetag
                    else
                        echo "Valid git branches for deployment- master, main, develop"
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

            }
        }
        stage('Helm-staging') {
            when {
                      expression { env.GIT_BRANCH_NAME == "develop" }
                }
            
            steps {
                script {
                       echo "${IMAGE_TAG}" 
                       sh "echo image tag is $IMAGE_TAG" 
                       sh "kubectl config use-context ${STAGING_CLUSTER}"
                       sh "cd devops/helm/$HELM_CHART_NAME && helm upgrade -f values-stag.yaml ${HELM_CHART_NAME} . --install  --set image.Imagetag=$IMAGE_TAG --namespace default --wait --timeout ${HELM_TIMEOUT}"
                }
                    
            }
        }

        stage('Approval') {
                when {
                      expression { env.GIT_BRANCH_NAME == "master"  && env.GIT_BRANCH_NAME == "main" }
                }

                steps {
                    script {
                        def userInput = input(id: 'confirm', message: 'Deploy production?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Production Deployment', name: 'confirm'] ])
                    }
                }
        }

        stage('Helm-prod') {
            when {
                      expression { env.GIT_BRANCH_NAME == "master" && env.GIT_BRANCH_NAME == "main" }
                }
            
            steps {
                script {

                       echo "${IMAGE_TAG}" 
                       sh "echo image tag is $IMAGE_TAG" 
                       sh "kubectl config use-context ${PROD_CLUSTER}"
                       sh "cd devops/helm/$HELM_CHART_NAME && helm upgrade -f values-prod.yaml ${HELM_CHART_NAME} . --install  --set image.Imagetag=$IMAGE_TAG --namespace default --wait --timeout ${HELM_TIMEOUT}"
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
