desc "This will drop the database, recreate it and repopulate it"
task :dropandimport => ["db:reset", "jdb:import_data"]

