#!/bin/sh
URL=$1
curl -o- -L ${URL} | tar xvz -C /usr/local/bin &&\
chmod +x /usr/local/bin/oc