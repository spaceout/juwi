class SettingsController < ApplicationController
  def index
    @settings = Setting.all
  end
  def edit
    @setting = Setting.find(params[:id])
  end
  def update
    @setting = Setting.find(params[:id])
    if @setting.update_attributes(params[:setting])
      flash[:notice] = "Setting Updated"
    else
      flash[:alert] = "Couldn't Update Setting, fucker"
    end
    redirect_to action: "show"
  end
  def show
    @setting = Setting.find(params[:id])
  end
  def new
    @setting = Setting.new
  end
  def create
    @setting = Setting.new(params[:setting])
    if @setting.save
      redirect_to action: 'index'
    else
      render :new
    end
  end
  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy
    redirect_to action: "index"
  end
end
 
