class SettingsController < ApplicationController
  def index
    @settings = Settings.all
  end
  def edit
    @setting = Settings.find(params[:id])
  end
  def update
    @setting = Settings.find(params[:id])
    @setting.update_attribute(:value, params[:value])
    render :show
  end
  def show
    @setting = Settings.find(params[:id])
  end
end
 
