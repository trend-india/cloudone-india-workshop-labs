#!/bin/bash
exec &> /var/log/dsm-install.log
service docker start
service dsm_s start