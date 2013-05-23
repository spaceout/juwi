CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
namespace :tvr do
  desc "This updates tvrage data"
  task :update => :environment do
    require 'data_runner'
    puts "ballsack1"
    DataRunner.update_tvrage
    
  end
end

