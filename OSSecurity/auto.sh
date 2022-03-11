#!/bin/bash

# 找到所有设置uid位的程序
info=`find / -perm /u=s`
pro_list=$info
arr=($pro_list)

# 输出所有设置uid位的程序
echo "以下是设置uid位的程序列表"

if [ -d "/tmp/pro_list" ] &&[ -n "$arr" ]; then
     rm /tmp/pro_list
fi


for((i=0;i<${#arr[@]};i++)); do
    echo "${arr[i]}"
    echo "${arr[i]}" >> /tmp/pro_list
done

# 测试其他用户是否可以使用ping命令
read -s -n1 -p "按任意键继续 ... "

# 删除所有设置uid位的程序权能
for((i=0;i<${#arr[@]};i++)); do
    setcap -r ${arr[i]}
    chmod u-s ${arr[i]}
done
echo -e "\n已删除所有设置uid位的程序权能"
echo "退出程序"