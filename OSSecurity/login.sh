#!/bin/bash

[ "$PAM_TYPE" == "open_session" ] || exit 0

delcap(){
    # 找到所有设置权能的程序
    while read line
    do
        setcap -r $line
    done < /tmp/pro_list
}

if [ "$PAM_USER" == "os_ping" ]; then
    delcap
	setcap cap_net_raw+eip /usr/bin/ping
	echo "os_ping用户只可以使用ping命令"
elif [ "$PAM_USER" == "os_passwd" ]; then
    delcap
     # CAP_CHOWN ,CAP_DAC_OVERRIDE ,CAP_FOWNER
     setcap cap_chown,cap_dac_override,cap_fowner+eip /usr/bin/passwd
     echo "os_passwd用户只可以使用passwd命令"
else
    delcap
    echo "非特定用户登录，无任何权限"
fi
