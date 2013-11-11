class HomeController < ApplicationController
  def index
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)
    @episodes = Episode.where("ttdb_season_number > 0 AND ttdb_episode_airdate < ?", DateTime.now)
    @completeness = (100 - (@episodes.missing.count.to_f  / @episodes.count.to_f) * 100).round(2)
  end
  def update
    require 're_namer'


    @blerm = "BOO!"
    render 'home'
  end
  def rename
    require 'xmlsimple'
    require 're_namer'
    require 'fileutils'

    config = YAML.load_file(File.join(Rails.root,'/settings/settings.yml'))["config"]
    rename_input_dir = config["renamedir"]
    rename_output_dir = config["destinationdir"]
    @blerm = Renamer.process_dir(rename_input_dir, rename_output_dir)

    #@blerm = "BOO!"
    render 'home/worker'
  end
end
