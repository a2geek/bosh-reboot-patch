#!/bin/bash

# A Monit "stop all" followed by "restart all" is frequently required upon reboot.
# This script attempts to watch monit status before each stage.
(
  function zerocheck() {
    nonzero=$(curl --silent --user $(cat /var/vcap/monit/monit.user) http://127.0.0.1:2822/_status?format=xml | 
                sed 's/></>\n</g' | 
                sort | 
                uniq -c | 
                grep $1 | 
                grep -v \">0<\" | 
                wc -l)
    return $nonzero
  }

  function waitpendingaction() {
    while ! zerocheck pendingaction
    do
      sleep 10
    done
  }

  export PATH=/var/vcap/bosh/bin/:$PATH

  waitpendingaction
  monit stop all
  waitpendingaction
  monit start all
) &
disown
