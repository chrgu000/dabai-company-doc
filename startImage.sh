#!/bin/bash

#操作/项目路径(Dockerfile存放的路劲)
BASE_PATH=/home/apps/docker/jingle-web-api/target
BAK_PATH=/home/apps/backup/jingle

#项目名称
PROJECT_NAME=jingle-web-api-1.1.0-SNAPSHOT

#docker 镜像/容器名字或者jar名字 这里都命名为这个
IMAGES_NAME=dabaikeji/jingle
#容器id
CID=$(docker ps | grep "$IMAGES_NAME" | awk '{print $1}')
#镜像id
IID=$(docker images | grep "$IMAGES_NAME" | awk '{print $3}')
 
DATE=`date +%Y%m%d%H%M` 
# 备份
function backup(){
	if [ -f "$BASE_PATH/$PROJECT_NAME.jar" ]; then
    	echo "$PROJECT_NAME.jar 备份..."
        	cp $BASE_PATH/$PROJECT_NAME.jar $BAK_PATH/$PROJECT_NAME-$DATE.jar
        echo "备份 $PROJECT_NAME.jar 完成"
    else
    	echo "$BASE_PATH/$PROJECT_NAME.jar不存在，跳过备份"
    fi
}
 
# 构建docker镜像
function build(){
        IID=$(docker images | grep "$IMAGES_NAME" | awk '{print $3}')
	if [ -n "$IID" ]; then
		echo "存在$IMAGES_NAME镜像，IID=$IID"
	else
		echo "不存在$IMAGES_NAME镜像，开始构建镜像"
			cd $BASE_PATH
		docker build -f $BASE_PATH/Dockerfile -t registry.cn-shenzhen.aliyuncs.com/dabaikeji/jingle:1.2 .
	fi
}

#updload images
function upload(){
     IID=$(docker images | grep "$IMAGES_NAME" | awk '{print $3}')    
     echo "镜像ID=$IID ..."
     docker login --username=珠海大白 --password=Dabai@2019 registry.cn-shenzhen.aliyuncs.com
     docker tag $IID registry.cn-shenzhen.aliyuncs.com/dabaikeji/jingle:1.2
     docker push registry.cn-shenzhen.aliyuncs.com/dabaikeji/jingle:1.2
}

#启动本地镜像
function start(){
     CID=$(docker ps -a | grep "$IMAGES_NAME" | awk '{print $1}')
     IID=$(docker images | grep "$IMAGES_NAME" | awk '{print $3}')
     if [ -z $CID ];then
        echo "the container $CID is not exist..."
        docker run -d -p 9099:8088 registry.cn-shenzhen.aliyuncs.com/dabaikeji/jingle:1.2 /bin/bash
     else
       echo "the container $CID exist"
       echo "stop container $CID..."
       docker stop $CID
       echo "delete container $CID..."
       docker rm -f $CID
       echo "delete image ID = $IID..."
       docker rmi -f $IID
       echo "pull images ..."
       docker pull registry.cn-shenzhen.aliyuncs.com/dabaikeji/jingle:1.2
       echo "start container"
       docker run -d -p 9099:8088 registry.cn-shenzhen.aliyuncs.com/dabaikeji/jingle:1.2 /bin/bash
     fi
} 

#删除本地镜像
function delete(){
     IID=$(docker images | grep "$IMAGES_NAME" | awk '{print $3}')    
     if [ -z $IID ];then
        echo "the process $IID is not exist..."
     else
       echo "the process $IID exist"
       docker rmi -f $IID
     fi
} 

# 运行docker容器
function run(){
	backup
	build
	upload
        start
}
 
#入口
run 
