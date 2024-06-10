#!/bin/bash
envsubst < /etc/supervisor/conf.d/supervisord.conf.template > /etc/supervisor/conf.d/supervisord.conf
cat /etc/supervisor/conf.d/supervisord.conf