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
# Yea I should just write this in python right.
#
TOTAL=0
COUNT=20
TIME=1
NAME=$(nova list | awk '{ print $2 }' | grep "\-" )
for i in ${NAME}
do
        if ( nova delete ${i} ) ; then
                echo -n "."
                TOTAL=$(($TOTAL+1))
        fi

        if ((TIME++ / ${COUNT})) ; then
                echo "$TOTAL"
                TIME=1
        fi
done
if ! ((TIME-- / ${COUNT})) ; then
        echo " "
fi

echo "----------"
echo "Total: ${TOTAL}"
