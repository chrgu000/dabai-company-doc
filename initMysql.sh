#!/bin/bash

bak_path="/home/apps/backup/mysql"
sql_path="/home/apps/mysql/dev/next"
init_path="/home/apps/mysql/dev/initDB"

sql_files=$(ls $sql_path)
#筛选出最新上传的文件
echo "step 1 =============开始比对脚本，刷选初最新的脚本..."
for sql_filename in $sql_files
  do
     if [ -f "$bak_path/$sql_filename" ]; then
       rm -f $sql_path/$sql_filename
     else
       chmod 777 $sql_path/$sql_filename
    fi
done

#数据库连接
username=root
password=Dabai2019#test
db_name=jingle_test
MYDATE=`date +%F'-'%T'-'%w`
log_file=/home/apps/logs/mysql/exec_${MYDATE}.log

#执行新增脚本
echo "step 2 =============开始执行新增数据库脚本..."
sql_files=$(ls $sql_path|sort -n)
for file in $sql_files
do
 echo "开始遍历脚本：$sql_path/$file"
 if [ -f "$sql_path/$file" ]; then
    postfix=`echo $sql_path/$file | awk -F'.' '{print "."$NF}'`
    if [ $postfix = ".sql" ]; then
       mysql -h10.42.40.73 -u$username -p$password --default-character-set=utf8 ${db_name} < $sql_path/$file >& error.log
       echo $file 
       echo -e "\n===========$file=============\n" >>${LOG_FILE}
       cat error.log >>${LOG_FILE} #输出执行日志
       error=`grep ERROR error.log` #读取错误日志信息
       if [ -n "$error" ]; then #如果有错误就退出程序
          echo $error
          exit
       fi
    else
       echo "您已经取消操作!"
       exit
    fi
 else
   echo "脚本不存在：$sql_path/$file"
 fi
done


#拷贝最新的脚本到备份文件夹中
echo "step 3 =============开始备份脚本..."
sql_files=$(ls $sql_path)
for newfile in $sql_files
do
  cp $sql_path/$newfile $bak_path
done

#清理redis
echo "step 4 =============开始清理redis数据... "
db=0
redis-cli -h 10.42.96.190 -p 6379 << END
select ${db}
flushdb
END



#初始化数据库数据
echo "step 5 =============开始清理mysql数据库..."
files=$(ls $init_path|sort -n)

for initfile in $files
do
    postfix=`echo $init_path/$initfile | awk -F'.' '{print "."$NF}'`
    if [ $postfix = ".sql" ]; then
       mysql -h10.42.40.73 -u$username -p$password --default-character-set=utf8 ${db_name} < $init_path/$initfile >& initDBError.log
       echo $initfile
       echo -e "\n===========$file=============\n" >>${LOG_FILE}
       cat initDBError.log >>${LOG_FILE} #输出执行日志
       error=`grep ERROR initDBError.log` #读取错误日志信息
       if [ -n "$error" ]; then #如果有错误就退出程序
          echo $error
          exit
       fi
    else
       echo "您已经取消操作!"
       exit
    fi
done

