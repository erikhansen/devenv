#!/usr/bin/env bash
##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

########################################
# install and configure redis service

set -e

yum install -y redis

if [[ -f ./etc/redis.conf ]]; then
    cp ./etc/redis.conf /etc/redis.conf
fi
