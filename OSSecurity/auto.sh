#!/bin/sh
# 找到所有设置uid位的程序
info=`find / -perm /u=s`
pro_list=$info
arr=($pro_list)
# 输出所有设置uid位的程序
echo "以下是设置uid位的程序列表"
for((i=0;i<${#arr[@]};i++)); do
    echo "${arr[i]}"
done

