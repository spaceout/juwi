#!/bin/sh
cd $HOME/juwi
script/delayed_job stop
clockworkd -c app/clock.rb stop
kill $(cat $HOME/juwi/tmp/pids/server.pid)

cd $HOME/juwi
script/delayed_job start
clockworkd -c app/clock.rb -d $HOME/juwi/ -l start
rails s -d
