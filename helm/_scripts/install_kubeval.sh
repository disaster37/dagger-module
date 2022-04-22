#!/bin/sh
URL=$1
curl -s ${URL} -o- | tar xvz -C /usr/local/bin --strip-components=0
chmod +x /usr/local/bin/kubeval