#!/bin/sh
cd $HOME/juwi
script/delayed_job start
clockworkd -c app/clock.rb -d $HOME/juwi/ -l start
rails s -d
