//开发环境
def DEPLOY_DEV_HOST = [ '139.198.171.190']
//测试环境
def DEPLOY_TEST_THOST = [ '139.198.171.190']
//Master环境
def DEPLOY_Master_THOST = [ '139.198.171.190']
//生产环境
def DEPLOY_PRO_THOST = [ '139.198.171.190']

pipeline {
    
    agent any
    environment {

        project_name = "${JOB_NAME}"

        git_url = "git@github.com:yanh19930226/mytest.git"  
        
        haror_auth="harbor"  
        harbor_url="8.130.109.62"  
        harbor_project_name = "${JOB_NAME}"
        
        imageName="${project_name}:${branch}"

        tagImageName="${harbor_url}/${harbor_project_name}/${project_name}:${branch}" 
    }

    options {
        timestamps()  //构建日志带上时间
        disableConcurrentBuilds()   // 不允许同时执行流水线
        timeout(time: 5, unit: "MINUTES")   //设置流水线运行超过5分钟Jenkins将中止流水线
        buildDiscarder(logRotator(numToKeepStr: "10"))   //表示保留10次构建历史
    }

    parameters {
       choice (name: 'deploymode',choices: ['deploy', 'rollback'],description: '选择部署方式', )
       //git参数
       gitParameter(
             branch: '',
             branchFilter: 'origin.*/(.*)',
             defaultValue: 'main', // default value 必填
             name: 'branch',
             type: 'PT_BRANCH_TAG',
             description: '选择git分支'
             )
       string( name :'port',defaultValue:'',description:'服务port')
       string( name :'containerport',defaultValue:'',description:'容器port')
       choice(name: 'sonarqube', choices: ['false','true'],description: '是否进行代码质量检测')  
    }


    stages {
        // stage ("Git拉取代码") {
        //     when {
        //         environment name:'deploymode', value:'deploy' 
        //     }           
        //     steps { 

        //         checkout([$class: 'GitSCM', 
        //            branches: [[name: '${branch}']],
        //            extensions: [], 
        //            userRemoteConfigs: [[credentialsId: 'jenkins',
        //            url: "${git_url}"]]]
        //           )
        //     }
        // }

        stage('代码质量检测') {
            // when {
            //     anyOf {
            //           environment name: 'sonarqube', value: 'true'
            //         //   environment name: 'deploymode', value: 'deploy'
            //     }
            // } 
            steps {

                 kubeconfig(credentialsId: 'k8s', serverUrl: 'https://139.198.171.190:6443') {
                 sh 'kubectl get pods'
            }
        }

        // stage ("构建镜像") {
        //     when {
        //         environment name:'deploymode', value:'deploy' 
        //     }    
        //     steps {  
               
        //         script{

        //            //mian
             
        //            sh "docker build -t  ${imageName} ."
               
        //            sh "docker tag ${imageName} ${tagImageName}"

        //         }
        //     }
        // }

        //  stage('制作发布镜像发布') {

        //     when {

        //         environment name:'deploymode', value:'deploy'

        //     }  

        //     steps {
               
        //         withCredentials([usernamePassword(credentialsId: "${haror_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {

        //             echo "push image"
                    
        //             sh "docker login -u ${username}  -p ${password} ${harbor_url}"
                   
        //             sh "docker push ${tagImageName}"

        //             echo "镜像上传成功"

        //             sh "docker rmi -f ${imageName}"

        //             sh "docker rmi -f ${tagImageName}"
                    
        //             echo "删除本地镜像成功"
        //         }
        //     }
        // }

    //    stage('Apply Kubernetes files') {
    //              kubeconfig(credentialsId: 'k8s', serverUrl: 'https://139.198.171.190:6443') {
    //              sh 'kubectl get pods'
    //     }
    //    }

        stage('清理工作空间') {
            steps {
              cleanWs(
                  cleanWhenAborted: true,
                  cleanWhenFailure: true,
                  cleanWhenNotBuilt: true,
                  cleanWhenSuccess: true,
                  cleanWhenUnstable: true,
                  cleanupMatrixParent: true,
                  // 这个选项是关闭延时删除，立即删除
                  disableDeferredWipeout: true,
                  deleteDirs: true
              )
            }
        }
    }

     post {
       
        aborted {
            //当此Pipeline 终止时打印消息
            echo 'aborted'
        }
        changed {
            //当pipeline的状态与上一次build状态不同时打印消息
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
