desc "This will drop the database, recreate it and repopulate it"
task :dropandimport => ["db:drop", "db:migrate", "jdb:importData"]

