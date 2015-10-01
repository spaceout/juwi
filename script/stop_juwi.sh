#!/bin/sh
cd $HOME/juwi
script/delayed_job stop
clockworkd -c app/clock.rb stop
kill $(cat $HOME/juwi/tmp/pids/server.pid)
