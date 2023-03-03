 
#! /bin/sh
#接收外部参数
 
#harbor地址
harbor_url=$1
#harbor里的项目名称
harbor_project_name=$2
#代码的项目名称
project_name=$3
#打的标签的名称
tag=$4
#对外暴露的端口
port=$5
 
imageName=$harbor_url/$harbor_project_name/$project_name:$tag
containerName="${harbor_project_name}__${project_name}__${tag}_c"
echo "镜像名${imageName}"
echo "容器名名${containerName}"
#查询容器是否存在，存在则删除
containerId=`docker ps -a | grep -w ${project_name}:${tag}  | awk '{print $1}'`
if [ "$containerId" !=  "" ] ; then
    #停掉容器
    docker stop $containerId
 
    #删除容器
    docker rm $containerId
  
  echo "成功删除容器"
fi
 
#查询镜像是否存在，存在则删除
imageId=`docker images | grep -w $project_name  | awk '{print $3}'`
 
if [ "$imageId" !=  "" ] ; then
      
    #删除镜像
    docker rmi -f $imageId
  
  echo "成功删除镜像"
fi
 
# 登录Harbor
docker login -u admin -p Harbor12345 $harbor_url
 
# 下载镜像
docker pull $imageName
 
# 启动容器
docker run -d -p $port:80  --name ${containerName} $imageName  --restart=always
 
echo "容器启动成功"