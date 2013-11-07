TTDBCACHE = File.join(Rails.root,'/ttdbdata/')
CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
namespace :jdb do
  desc "This refreshes all data for a single show passed in as argument"
  task :update_show, [:showname] => :environment do |t, args|
    require 'jdb_helper'
    showname = args[:showname] || 'none'
    JdbHelper.update_show(showname)
  end
end

