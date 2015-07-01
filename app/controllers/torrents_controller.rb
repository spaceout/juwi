class TorrentsController < ApplicationController

def remove_torrent
  require 'xmission_api'
  xmission = XmissionApi.new(
    :username => Setting.get_value("transmission_user"),
    :password => Setting.get_value("transmission_password"),
    :url => Setting.get_value("transmission_url")
  )
  xmission.remove(Torrent.find(params[:id]).xmission_id)
  redirect_to(:back)
end


  # GET /torrents
  # GET /torrents.json
  def index
    @torrents = (Torrent.all.sort_by &:time_started).reverse!

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.json
  def show
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @torrent }
    end
  end

  # GET /torrents/new
  # GET /torrents/new.json
  def new
    @torrent = Torrent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @torrent }
    end
  end

  # GET /torrents/1/edit
  def edit
    @torrent = Torrent.find(params[:id])
  end

  # POST /torrents
  # POST /torrents.json
  def create
    @torrent = Torrent.new(params[:torrent])

    respond_to do |format|
      if @torrent.save
        format.html { redirect_to @torrent, notice: 'Torrent was successfully created.' }
        format.json { render json: @torrent, status: :created, location: @torrent }
      else
        format.html { render action: "new" }
        format.json { render json: @torrent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /torrents/1
  # PUT /torrents/1.json
  def update
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      if @torrent.update_attributes(params[:torrent])
        format.html { redirect_to @torrent, notice: 'Torrent was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @torrent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /torrents/1
  # DELETE /torrents/1.json
  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy

    respond_to do |format|
      format.html { redirect_to torrents_url }
      format.json { head :no_content }
    end
  end
end
