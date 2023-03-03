//开发环境
def DEPLOY_DEV_HOST = [ '39.101.1.156']
//测试环境
def DEPLOY_TEST_THOST = [ '39.101.1.156']
//Master环境
def DEPLOY_Master_THOST = [ '39.101.1.156']
//生产环境
def DEPLOY_PRO_THOST = [ '39.101.1.156']

pipeline {
    
    agent any
    environment {

        project_name = "${JOB_NAME}"

        git_url = "git@codeup.aliyun.com:617109303962cc4bc2b6bdf6/net/In66.Web.git"  
        
        haror_auth="harborid"  
        harbor_url="39.101.1.156:89"  
        harbor_project_name = "${JOB_NAME}"
        
        imageName="${project_name}:${branch}"

        tagImageName="${harbor_url}/${harbor_project_name}/${project_name}:${branch}" 
    }

    options {
        timestamps()  //构建日志中带上时间
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
             defaultValue: 'master', // default value 必填
             name: 'branch',
             type: 'PT_BRANCH_TAG',
             description: '选择git分支'
             )

       choice(name: 'sonarqube', choices: ['false','true'],description: '是否进行代码质量检测')  
    }


    stages {
        stage ("Git拉取代码") {
            when {
                environment name:'deploymode', value:'deploy' 
            }           
            steps { 

                // git branch: "${branch}", credentialsId: 'jenkins', url: "${git_url}"

                checkout([$class: 'GitSCM', 
                   branches: [[name: '${branch}']],
                   extensions: [], 
                   userRemoteConfigs: [[credentialsId: 'jenkins',
                   url: "${git_url}"]]]
                  )
            }
        }

        stage('代码质量检测') {
            when {
                anyOf {
                      environment name: 'sonarqube', value: 'true'
                    //   environment name: 'deploymode', value: 'deploy'
                }
            } 
            steps {

                echo '代码质量检测'

                script {
                    scannerHome = tool 'SonarQubeScanner'
                }

                withSonarQubeEnv('sonarqube') {
                  
                  sh "${scannerHome}/bin/sonar-scanner"
              }
            }
        }

        stage ("代码构建镜像") {
            when {
                environment name:'deploymode', value:'deploy' 
            }    
            steps {  
               
                script{

                   //获取git当前head简短
                   //build_tag = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
             
                   sh "docker build -t  ${imageName} ."
               
                   sh "docker tag ${imageName} ${tagImageName}"

                }
            }
        }

         stage('制作发布镜像发布') {

            when {

                environment name:'deploymode', value:'deploy'

            }  

            steps {
               
                withCredentials([usernamePassword(credentialsId: "${haror_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {

                     echo "push image"
                    
                     sh "docker login -u ${username}  -p ${password} ${harbor_url}"
                   
                     sh "docker push ${tagImageName}"

                     echo "镜像上传成功"

                     sh "docker rmi -f ${imageName}"

                     sh "docker rmi -f ${tagImageName}"

                     echo "删除本地镜像成功"
                }
            }
        }

        stage ("部署镜像") {
            when {
                environment name:'deploymode', value:'deploy' 
            }
            steps {  
                script {
                    switch("${branch}"){
                        case 'dev':
                            println("开始部署${branch}分支")
                            for (deployip in DEPLOY_DEV_HOST){
                                  echo "服务器Ip:${deployip}"
                                  sshPublisher(publishers: [sshPublisherDesc(configName: deployip, transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/opt/jenkins_shell/test.sh", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                  echo "${branch}部署完成"
                            }
                        break;
                        case 'test':
                            println("开始部署${branch}分支")
                            for (deployip in DEPLOY_TEST_THOST){

                                  echo "服务器Ip:${deployip}"
                                  sshPublisher(publishers: [sshPublisherDesc(configName: deployip, transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/opt/jenkins_shell/test.sh", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                  echo "${branch}部署完成"
                            }
                            break;
                        case 'master':
                            println("开始部署${branch}分支")
                            for (deployip in DEPLOY_Master_THOST){

                                   echo "服务器Ip:${deployip}"

                                   sshPublisher(publishers: [sshPublisherDesc(configName: deployip, transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/opt/jenkins_shell/test.sh", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])

                                   echo "${branch}部署完成"
                            }
                            break;
                        default:
                            println("开始部署${branch}分支")
                            for (deployip in DEPLOY_PRO_THOST){

                                  echo "服务器Ip:${deployip}"

                                  sshPublisher(
                                        publishers: [sshPublisherDesc(
                                            configName: deployip, 
                                            transfers: [sshTransfer(cleanRemote: false,
                                            excludes: '',
                                            execCommand: "/opt/jenkins_shell/test.sh", 
                                            execTimeout: 120000,
                                            flatten: false, makeEmptyDirs: false, 
                                            noDefaultExcludes: false, patternSeparator: '[, ]+',
                                            remoteDirectory: '',
                                            remoteDirectorySDF: false,
                                            removePrefix: '', 
                                            sourceFiles: '')], 
                                            usePromotionTimestamp: false, 
                                            useWorkspaceInPromotion: false,
                                            verbose: false)]
                                         )
                                  echo "${branch}部署完成"
                            }
                            echo "${branch}部署完成"
                            break;
                    }   
                }              
            }
        }
 
        stage ("回滚镜像") {
            when {
                environment name:'deploymode', value:'rollback' 
            }
            steps {  
            println("开始回滚")
                script {
                    switch("${branch}"){
                        case 'dev':
                            println("开始回滚${branch}环境")
                            for (rollbackip in DEPLOY_PRO_THOST){
                                sshPublisher(publishers: [sshPublisherDesc(configName: deployip, transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/opt/jenkins_shell/rollback.sh.sh $harbor_url $harbor_project_name $project_name $imagetag $port", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                echo "回滚完成"
                            }
                        break;
                        case 'test':
                            println("开始回滚${branch}环境")
                            for (rollbackip in DEPLOY_PRO_THOST){
                                sshPublisher(publishers: [sshPublisherDesc(configName: deployip, transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/opt/jenkins_shell/rollback.sh.sh $harbor_url $harbor_project_name $project_name $imagetag $port", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                echo "回滚完成"
                            }
                            break;
                        case 'master':
                            println("开始回滚${branch}环境")
                            for (rollbackip in DEPLOY_Master_THOST){
                                sshPublisher(publishers: [sshPublisherDesc(configName: deployip, transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: "/opt/jenkins_shell/rollback.sh.sh $harbor_url $harbor_project_name $project_name $imagetag $port", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                echo "回滚完成"
                            }
                            break;
                         default:
                            println("开始回滚${branch}分支")
                            echo "${branch}回滚完成"
                            break;
                    }   
                }
            }
        }
       
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
        success {
            dingtalk (
                robot: 'JenkinsRobot',
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
                robot: 'JenkinsRobot',
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
