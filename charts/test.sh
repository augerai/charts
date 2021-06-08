#!/bin/sh

read -r -d '' PARAMS <<- EOM
  --set brokerHttpUrl=https://rabbitmq.com/vhost
  --set brokerUrl=amqp://rabbitmq.com/vhost
EOM

set -x # Echoes executed commands

# Smoke test, if rendering is broken Helm will return non-zero exit code
# Render twice with only required and with all params
helm template auger-worker $PARAMS
# --debug
