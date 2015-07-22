class TfilesController < ApplicationController
  # GET /tfiles
  # GET /tfiles.json
  def index
    @torrent = Torrent.find(params[:torrent_id])
    @tfiles = @torrent.tfiles.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tfiles }
    end
  end

  def rename
    #if the new_name is nil, then just retry renaming

    tfile = Tfile.find(params[:id])
    puts tfile.name
    puts "id: #{params[:id]}"
    puts "new_name #{params[:new_name]}"
    puts "overwrite #{params[:overwrite_enabled]}"
    overwrite = false
    if params[:overwrite_enabled] == "on"
      overwrite = true
    end
    new_name = nil
    if params[:new_name] = nil
      new_name = name
    end
    tfile.process_completed_tfile(params[:new_name], overwrite)
    tfile.torrent.update_rename_status
    if tfile.torrent.rename_status == true
      tfile.torrent.cleanup_torrent_files
    end
    redirect_to(:back)
  end


  # GET /tfiles/1
  # GET /tfiles/1.json
  def show
    @tfile = Tfile.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tfile }
    end
  end

  # GET /tfiles/new
  # GET /tfiles/new.json
  def new
    @tfile = Tfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tfile }
    end
  end

  # GET /tfiles/1/edit
  def edit
    @tfile = Tfile.find(params[:id])
  end

  # POST /tfiles
  # POST /tfiles.json
  def create
    @tfile = Tfile.new(params[:tfile])

    respond_to do |format|
      if @tfile.save
        format.html { redirect_to @tfile, notice: 'Tfile was successfully created.' }
        format.json { render json: @tfile, status: :created, location: @tfile }
      else
        format.html { render action: "new" }
        format.json { render json: @tfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tfiles/1
  # PUT /tfiles/1.json
  def update
    @tfile = Tfile.find(params[:id])

    respond_to do |format|
      if @tfile.update_attributes(params[:tfile])
        format.html { redirect_to @tfile, notice: 'Tfile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tfiles/1
  # DELETE /tfiles/1.json
  def destroy
    @tfile = Tfile.find(params[:id])
    @tfile.destroy

    respond_to do |format|
      format.html { redirect_to tfiles_url }
      format.json { head :no_content }
    end
  end
end
