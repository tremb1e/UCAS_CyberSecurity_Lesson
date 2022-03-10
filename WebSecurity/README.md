# 一.使用工具的内网主机探测爆破脚本

## 思路如下：

## 1.确定网卡，显示本机IP，使用CIDR显示内网范围

## 2.查看linux发行版和内核版本号

## 3.备份并改源

## 4.安装nmap和hydra

## 5.将源恢复（隐藏入侵）

## 6.使用nmap探测内网存活主机

## 7.使用hydra对内网存活主机进行爆破

## 8.将结果保存在本地文件中

## 9.修改本地文件名称和生成时间，躲避简单的检查

## 10.删除其他生成文件

## 代码开源地址:https://github.com/Tremb1e/UCAS_CyberSecurity_Lesson/blob/main/WebSecurity/auto_tools.sh


# 二.不使用工具的内网主机探测爆破脚本

## 思路如下：

## 1.确定网卡，显示本机IP，使用CIDR显示内网范围

## 2.使用telnet遍历内网主机22端口，将存活主机写入本地文件中

## 3.使用openssh服务和expect交互模块通过双重循环进行密码遍历爆破

## 4.爆破成功后登录shell

## 5.发送一个文件名为ip+password的文件给爆破机器

## 6.删除本机新增文件和登录日志文件

## 7.将收到的所有ip+password名字提取到文件中，得到所有爆破成功的服务器IP和密码

## 8.删除多余生成文件、日志信息、修改最终得到的文件时间为系统创建时间

## 代码开源地址:https://github.com/Tremb1e/UCAS_CyberSecurity_Lesson/blob/main/WebSecurity/auto_nontools.sh