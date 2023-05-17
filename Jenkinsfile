pipeline {
  agent {
    kubernetes {
      label "jnlp"
      cloud "kubernetes"
      namespace "default"
      slaveConnectTimeout 1200
      yamlFile 'podtemplate.yaml'
    }
  }
  
  environment {
      
      //git
      GIT_CREDENTIAL_ID="git"
      GIT_URL = "git@github.com:yanh19930226/mytest.git" 
      
      //harbor
      HARBOR_CREDENTIAL_ID="harbor"
      HARBOR_URL="8.130.109.62"  
      HARBOR_PROJECT_NAME = "${JOB_NAME}" 

      //images
      PROJECT_NAME = "${JOB_NAME}"
      IMAGE_NAME="${PROJECT_NAME}:${BRANCH}"
      TAG_IMAGE_NAME="${HARBOR_URL}/${HARBOR_PROJECT_NAME}/${PROJECT_NAME}:${BRANCH}"

  }

  options {
     timestamps()  //构建日志中带上时间
     disableConcurrentBuilds()   // 不允许同时执行流水线
     timeout(time: 5, unit: "MINUTES")   //设置流水线运行超过5分钟Jenkins将中止流水线
     buildDiscarder(logRotator(numToKeepStr: "10"))   //表示保留10次构建历史
  }

  parameters {
      //部署方式
      choice (name: 'deploymode',choices: ['deploy', 'rollback'],description: '选择部署方式', )
      //git参数
      gitParameter(
         branch: '',
         branchFilter: 'origin.*/(.*)',
         defaultValue: 'main', // default value 必填
         name: 'BRANCH',
         type: 'PT_BRANCH_TAG',
         description: '选择git分支tag'
      )

      string( name :'port',defaultValue:'',description:'服务port')
      string( name :'containerport',defaultValue:'',description:'容器port')
      choice(name: 'sonarqube', choices: ['false','true'],description: '是否进行代码质量检测')  
  }

  stages {

    stage ("Git拉取代码") {

        //如果是部署模式重新拉取代码
        when {
            environment name:'deploymode', value:'deploy' 
        }

        steps { 
             container(name: 'docker') {
                checkout([
                     $class: 'GitSCM', 
                     branches: [[name: "${BRANCH}"]],
                     extensions: [], 
                     userRemoteConfigs: [[
                         credentialsId: "${GIT_CREDENTIAL_ID}",
                         url: "${GIT_URL}"
                     ]]
                ])
             }
        }
    }

   

    stage('构建镜像') {

        steps {
            container(name: 'docker') {

                 sh "docker build -t  ${IMAGE_NAME} ."
             
                 sh "docker tag ${IMAGE_NAME} ${TAG_IMAGE_NAME}"

            }
        }
    }

    stage('发布镜像') {

        when {
            environment name:'deploymode', value:'deploy'
        }

        steps {
               
            withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDENTIAL_ID}", passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                container(name: 'docker') {
                    echo "push image"
                
                    sh "docker login -u ${USERNAME}  -p ${PASSWORD} ${HARBOR_URL}"
                
                    sh "docker push ${TAG_IMAGE_NAME}"
                    echo "镜像上传成功"
                    sh "docker rmi -f ${IMAGE_NAME}"
                    sh "docker rmi -f ${TAG_IMAGE_NAME}"
                    
                    echo "删除本地镜像成功"
                      
               }
               
            }
        }
    }

    stage('kubernetes') {
         steps {
              withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDENTIAL_ID}", passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
//                kubeconfig(caCertificate: '''-----BEGIN CERTIFICATE-----
// MIICyDCCAbCgAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
// cm5ldGVzMB4XDTIxMDMyNTAwNTM0NVoXDTMxMDMyMzAwNTM0NVowFTETMBEGA1UE
// AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANnz
// L2nv5wofXJCeVRVRUFNKkBLEQkBl65ZMpcBmVNiaFSgdJ05E9VWLc7jGQVRMrnmV
// QR298eQtQStfnbSF4mH4keXAjLR9d0RrJ1yXsrMwpao5k9r+3h9RbtNwsmPnYKCO
// 2bHy1dezC6BZgVyuR7F2CNSokklSA7x6ekmcqNvGjjq+XbDbepZyajnz9vRDDoIm
// t+oLjSJ9S/VKyIOIXJEf1AkFjkGNPGIl6/GGPzlU8aO3bBQurzbxkO94quizwbjZ
// SAGJSp8syp2Zsn58S732wN6S552U9wfF+aBV03LK+NiDD6nWT8hjqPE+QkOyIXcG
// fstSkNMmz0vmLrWCP60CAwEAAaMjMCEwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
// /wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBACqOHgCn/7crvda1xHk2eoCqUWvK
// Tj0ow0tF7+8UZWFmNXW/pHU0kK+rHr1kxPclOVe59+EUpVPPCtEIFMfEXnCXR1eJ
// 7MggmIq9CbN9MeZ4Eh3YYUA2AXKP5fHulM7VNcFdzcLHqFi4xvLyUWo4yhzDsIbp
// pICoUkELotBfFb9RTZim3YbHdSwEOC8Qoma4ilZf7Pc5X8qPhGpkgoF3DT+yeuB8
// hHmOdCRTdJm9T39J6Y+I4ylJRoZZAcishmU2n1DBX6pMIL0U7AAErsi/JjmL10It
// /DC+0cZw6udNbzhMyEaGndrmhlUgi2pDYf3P9mqwMgpxEfxuOvtoI80dSKM=
// -----END CERTIFICATE-----''', credentialsId: 'hansl-token-7vqrc', serverUrl: 'https://10.0.254.101:8443') {
//     // some block
//         sh 'kubectl apply -f nginx.yaml'
//         }

                echo '=========begin kubectl==========='
                
                container(name: 'kubectl') {
                    

                   sh "kubectl get nodes --kubeconfig=/root/.kube/config"

                }
              }
          }
    }

  }
   post {

        aborted {
            dingtalk (
                robot: 'jenkins',
                type:'ACTION_CARD',
                title: "unstable: ${JOB_NAME}",
                text: [
                    "### [${env.JOB_NAME}](${env.JOB_URL}) ",
                    '---',
                    "- 任务：[${currentBuild.displayName}](${env.BUILD_URL})",
                    '- 状态：<font color=#CCCCCC >中止</font>',
                    "- 持续时间：${currentBuild.durationString}",
                    "- 执行人：${currentBuild.buildCauses.shortDescription}",
                  ]
            )
        }

        changed {
            echo 'changed'       
        }

        unstable {
           dingtalk (
                robot: 'jenkins',
                type:'ACTION_CARD',
                title: "unstable: ${JOB_NAME}",
                text: [
                    "### [${env.JOB_NAME}](${env.JOB_URL}) ",
                    '---',
                    "- 任务：[${currentBuild.displayName}](${env.BUILD_URL})",
                    '- 状态：<font color=#FF8000 >不稳定</font>',
                    "- 持续时间：${currentBuild.durationString}",
                    "- 执行人：${currentBuild.buildCauses.shortDescription}",
                  ]
            )
        }

        success {
            dingtalk (
                robot: 'jenkins',
                type:'ACTION_CARD',
                title: "success: ${JOB_NAME}",
                text: [
                    "### [${env.JOB_NAME}](${env.JOB_URL}) ",
                    '---',
                    "- 任务：[${currentBuild.displayName}](${env.BUILD_URL})",
                    '- 状态：<font color=#005EFF >成功</font>',
                    "- 持续时间：${currentBuild.durationString}",
                    "- 执行人：${currentBuild.buildCauses.shortDescription}",
                  ]
            )
        }

        failure {
            dingtalk (
                robot: 'jenkins',
                type:'ACTION_CARD',
                title: "fail: ${JOB_NAME}",
                text: [
                   "### [${env.JOB_NAME}](${env.JOB_URL}) ",
                    '---',
                    "- 任务：[${currentBuild.displayName}](${env.BUILD_URL})",
                    '- 状态：<font color=#EE0000 >失败</font>',
                    "- 持续时间：${currentBuild.durationString}",
                    "- 执行人：${currentBuild.buildCauses.shortDescription}",
                  ]
            )
        }
    }
}