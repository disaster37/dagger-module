#!/bin/sh
URL=$1
curl -o- -L ${URL} | tar xvz -C /usr/local/bin --strip-components=0
chmod +x /usr/local/bin/kubeconform