#!/bin/bash

sudo mkdir -p /etc/sft
okta_sftd="/etc/sft/sftd.yaml"
sudo rm $okta_sftd
sudo touch $okta_sftd

okta_canonical=`hostname`

RETURN_STRING=$(curl --silent --url "www.ifconfig.me" --write-out "\nHTTP_CODE:%{http_code}:" | tr "\n" " ")
# echo $RETURN_STRING # 123.012.234.201 HTTP_CODE:200:

IP="${RETURN_STRING%% *}"
# echo $IP # 123.012.234.201
# HTTP_CODE="${RETURN_STRING##*HTTP_CODE:}"
# HTTP_CODE="${HTTP_CODE%%:*}"
# echo $HTTP_CODE # 200

echo "AccessAddress: ${IP}" | sudo tee -a "${okta_sftd}"
echo "CanonicalName: ${okta_canonical}" | sudo tee -a "${okta_sftd}"
# echo "AltNames: ${okta_altnames}" | sudo tee -a "${okta_sftd}"

sudo systemctl restart sshd
sudo systemctl restart sftd
