#!/bin/bash

[[ ! $1 || ! $2 ]] && echo "$0 area_id name" && exit 1

area_id=$1
name=$2

dir=/data/web

sudo cd $dir

# 替换json文件ip
ip_wan=$(curl icanhazip.com)  #本机公网ip
echo "$ip_wan:"$ip_wan

# 生成p23.json
cat > p23.json <<EOF
{
    "area":{
        "$area_id":{
            "name":"$name",
            "svrlist":"http://$ip_wan:7000/server/list"
        }
    },
    "serverUrl":"http://$ip_wan:7000/server/list",
    "noticeUrl":"http://$ip_wan:7000/notice",
    "checkWhite":"http://$ip_wan:6008/api/check",
    "reportUrl":"http://$ip_wan:9000/api/",
    "resUrl":"http://aygexqcdn.tunyouhy.com/resUpdate",
    "whiteResUrl":"http://aygexqcdn.tunyouhy.com/resWhite"
}
EOF
sudo chown -R game:game /data/web/p23.json

cat p23.json



