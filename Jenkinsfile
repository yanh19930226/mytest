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