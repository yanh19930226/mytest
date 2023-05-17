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


      stage('kubernetes') {
         steps {
              withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDENTIAL_ID}", passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
//                kubeconfig(caCertificate: '''-----BEGIN CERTIFICATE-----
// MIIC/jCCAeagAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
// cm5ldGVzMB4XDTIzMDUwMTA4NTExN1oXDTMzMDQyODA4NTExN1owFTETMBEGA1UE
// AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKz+
// hRNLClyCgfiydGtBwicYV646DusoSSIG1kgv7Ao+wJ4JPpJX+A1cFkmeISOjsXgP
// hsySMFW2w/m3gKS0Zrl0SEfUOAc8bkAaFuqj5oan4PaHNpWHpkadVJ3CxFgnjsPw
// nHfcvOoDzLKdCxuMdmONwyV8FGItXWYWuPSdevwajGe2Gwnu7E73TKdiitY+TO7o
// qgNm92TF3qnuDtRuOSoQfwDk0b7/tCiqmmsw8YdZ331vFAiWXFKpYRA5oKn0GXXV
// e7Mwc8zy83w5z9+b/QRyo0CAXfmYIW+TO+9gXBzNzU9q7tIMQnFJFIB+1zLuvl23
// 3tbCCynDBy3JIugdzMUCAwEAAaNZMFcwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
// /wQFMAMBAf8wHQYDVR0OBBYEFHK00rUXyMXJqAVqCTnKpfLUhdArMBUGA1UdEQQO
// MAyCCmt1YmVybmV0ZXMwDQYJKoZIhvcNAQELBQADggEBAEJfNBjDCnT6+MQfCBzU
// gjtby4rP9DWhQ7HoqEG6sitf3ZVkn0oIAoQKJs3bC8m7uSA+Aj00xc71D1+m81CX
// Bikt+a8hKlCxDbxDe6Ye9cPQ1pUc2rCJIKS8FzbvXaAJ/AAwFu2HeK67Yy/rUWlV
// z62WK/DlAgpOAYl1nsXcV+YJchaX/5ITy1OOLXhzCJRgiHfI4l7uNhwdSyhXO1qT
// qbv/iWmwX9jvSGaiwQp8nSsZGVDQkYfwsbsC9AyabUS45ow6cEwnXWXNeC1atisz
// Sk/FGvavaS+r9cWUHnoyn8lMRuCGVIThsALpavsSQ1rEC3Jn1Ugn3HxcH0MRyHrQ
// xrE=
// -----END CERTIFICATE-----''', credentialsId: 'k8s', serverUrl: 'https://yande.org:6443') {
//     // some block
//         sh 'kubectl get nodes'
//         }

                echo '=========begin kubectl==========='

                container(name: 'kubectl') {
                    

                   sh "kubectl get nodes --kubeconfig=/root/.kube/config"

                }
              }
          }
    }

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