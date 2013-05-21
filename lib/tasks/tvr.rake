CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
namespace :tvr do
  desc "This updates tvrage data"
  task :update => :environment do
    require 'data_runner'
    DataRunner.update_tvrage_data
  end
end

