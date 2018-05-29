#!/bin/bash

wp() {
  su -s /bin/bash -m www-data -c -- 'wp "$@"' -- -- "$@"
}

#Add custom entrypoint.sh functions, scripts to the wordpress deployment