class SettingsController < ApplicationController
  def index
    @settings = Settings.all
  end
  def edit
    @setting = Settings.find(params[:id])
  end
end
 
