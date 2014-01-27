#!/bin/bash
# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
#
# Authored by Yazz D. Atlas <yazz.atlas@hp.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#
# Ugly, but lets you create some images to do a quick test
#
#  ./simple-test test 1 10
#
# That will create VM's named test-0001 to test-0010 with a test.pem so you can 
# ssh into them.
#
source ~/stackrc

set -eubx
NAME=${1:-test}
START=${2:-1}
END=${3:-1}
FLAVOR=${4:-1l} ; # 1 == m1.small
IMAGE=${5:-precise-12.04.1-20130124} ; # a glance image you might have

# Add a key to nova using the first argument 
if ! $(nova keypair-list | grep -q " ${NAME} ") ; then
        if [ ! -f ${NAME}.pem ] ; then
                nova keypair-add ${NAME} > ${NAME}.pem
                chmod 600 ${NAME}.pem
        else
                ssh-keygen -e -f ${NAME}.pem > ${NAME}-pub.pem
                ssh-keygen -i -f ${NAME}-pub.pem > ${NAME}.pub
                nova keypair-add ${NAME} --pub-key ${NAME}.pub
        fi
fi

# Create images quickly but don't slam the API to fast
COUNT=10
TIME=1
SLEEP=30
for i in $(seq -f "%04g" ${START}  ${END}) ;
do
       if ((TIME++ / ${COUNT})) ; then
                nova list
                echo "Sleeping for ${SLEEP}"
                sleep ${SLEEP}
                TIME=0
       fi

# You can tweek this to make your testing easier.
#		--num-instances 10 \
#       --user-data my-cloud-init.txt \
#		--availability-zone RegionOne:node-cpu0002 \

        nova boot \
                --image ${IMAGE} \
                --flavor ${FLAVOR}  \
                --key_name ${NAME} ${NAME}-${i} || { echo 'my_command failed' ; exit 1; }
        sleep 5
done

# Lastly show what has be made
nova list
