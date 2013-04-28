CONFIG = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]

desc "This will download all images for current tvshows"
task :getttdbimages => :environment do
  require 'data_runner'
  Tvshow.all.each do |tvshow|
    next if File.exist?(File.join(Rails.root, "/public/images/", "#{tvshow.ttdb_show_id}_banner.jpg"))
    TtdbHelper.get_all_images(tvshow)
  end
end


