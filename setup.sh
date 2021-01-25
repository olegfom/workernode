#!/bin/bash

set -x

change_var_value () {
  sed -i "s<^[[:blank:]#]*\(${2}\).*<\1=${3}<" $1
}

change_yml_value () {
  sed -i "s<^\([[:blank:]#]*\)\(${2}\): .*<\1\2: ${3}<" $1
}


nohup /root/moresetup.sh &
exec /sbin/init --log-target=journal 3>&1


