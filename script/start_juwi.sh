#!/bin/sh
cd $HOME/juwi
script/delayed_job -n4 start
clockworkd -c app/clock.rb -d $HOME/juwi/ -l start
rails s -d
