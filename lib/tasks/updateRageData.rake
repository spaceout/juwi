CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

desc "This updates tvrage data"
task :updateRageData => :environment do
  require 'data_runner'
  DataRunner.update_tvrage_data
end


