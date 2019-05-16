node {
  def acr = 'acrdemo3.azurecr.io'
  def appName = 'whoaim'
  def imageName = "${acr}/${appName}"
  def imageTag = "${imageName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  def appRepo = "acrdemo3.azurecr.io/whoaim:v1.0.0"

  checkout scm
  
 stage('Build the Image and Push to Azure Container Registry') 
 {
   app = docker.build("${imageName}")
   withDockerRegistry([credentialsId: 'acr-auth', url: "https://${acr}"]) {
      app.push("${env.BRANCH_NAME}.${env.BUILD_NUMBER}")
                }
  }


 stage ("Deploy Application on Azure Kubernetes Service")
 {
  switch (env.BRANCH_NAME) {
    // Roll out to canary environment
    case "canary":
        // Change deployed image in canary to the one we just built
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/canary/*.yaml")
        sh("kubectl --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/canary/")
        sh("echo http://`kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

    // Roll out to production
    case "master":
        // Change deployed image in master to the one we just built
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break
    
    case "dev":
        // Change deployed image in master to the one we just built
        sh("sudo kubectl get ns ${appName}-${env.BRANCH_NAME} || sudo kubectl create ns ${appName}-${env.BRANCH_NAME}")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl -n ${appName}-${env.BRANCH_NAME} get secret acr-auth || sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        } 
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/dev/*.yaml")
        sh("sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/dev/")
        sh("echo http://`sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/namespaces/${appName}-${env.BRANCH_NAME}/services/${appName}:80/proxy/"     
        break
    
    case "stage":
        // Change deployed image in master to the one we just built
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/stage/*.yaml")
        sh("sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/stage/")
        sh("echo http://`sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break


    // Roll out a default branch with dev environment 
    default:
        // Create namespace if it doesn't exist
        sh("sudo kubectl get ns ${appName}-${env.BRANCH_NAME} || sudo kubectl create ns ${appName}-${env.BRANCH_NAME}")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl -n ${appName}-${env.BRANCH_NAME} get secret acr-auth || sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }  
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/dev/*.yaml")
        sh("sudo kubectl --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/dev/")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/namespaces/${appName}-${env.BRANCH_NAME}/services/${appName}:80/proxy/"     
    }
  }
}