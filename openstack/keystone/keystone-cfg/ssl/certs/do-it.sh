#!/bin/bash
{{pillar['headers']['salt']['file']}}

echo " DO NOT RUN UNLESS YOU NEED TO"
exit
rm 01.pem ca* index.txt* req.pem serial* signing_cert.pem

touch /etc/keystone/ssl/certs/index.txt
echo "01" > /etc/keystone/ssl/certs/serial
SUBJECT="/C={{keystone.ssl.country}}/ST={{keystone.ssl.locality}}/L={{keystone.ssl.locality}}/O={{keystone.ssl.org_name}}/CN={{keystone.ssl.common_name}}"

openssl genrsa {{keystone.ssl.default_bits}} \
        -out /etc/keystone/ssl/certs/cakey.pem \
        -config /etc/keystone/ssl/certs/openssl.conf \
        -subj ${SUBJECT} > /etc/keystone/ssl/certs/cakey.pem

openssl req -new -x509 -extensions v3_ca \
        -passin pass:None \
        -key /etc/keystone/ssl/certs/cakey.pem \
        -out /etc/keystone/ssl/certs/ca.pem \
        -days {{ keystone.ssl.default_days }}\
        -config /etc/keystone/ssl/certs/openssl.conf \
        -subj ${SUBJECT}

openssl req -new -key /etc/keystone/ssl/private/signing_key.pem \
        -nodes \
        -extensions v3_req \
        -out /etc/keystone/ssl/certs/req.pem \
        -config /etc/keystone/ssl/certs/openssl.conf \
        -subj ${SUBJECT}

openssl ca -batch -out /etc/keystone/ssl/certs/signing_cert.pem \
        -config /etc/keystone/ssl/certs/openssl.conf \
        -infiles /etc/keystone/ssl/certs/req.pem
