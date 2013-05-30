desc "This will update ttdb, tvr, then jdb"
task :update => ["xbmc:update","ttdb:update", "tvr:update", "jdb:update"]

