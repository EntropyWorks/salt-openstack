#!/bin/bash
#
# Create a db for OpenStack.
#
#  
#

function label {
    set +x
    echo "#####################################################"
        echo "# "
    echo "#   $1"
        echo "# "
    echo "#####################################################"
    set -eux
}


function create_db {
  label "Creating Database for $1"
  local sql="
    drop database if exists $1; -- TODO: remove this
    create database if not exists $1;
    grant all on $1.* to '$2'@'%'         identified by '$3';
    grant all on $1.* to '$2'@'*'         identified by '$3';
    grant all on $1.* to '$2'@'localhost' identified by '$3';
    flush privileges;"
  mysql -uroot -e "$sql"
}

create_db $1 $2 $3

