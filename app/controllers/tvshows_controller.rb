class TvshowsController < ApplicationController
  # GET /tvshows
  # GET /tvshows.json
  def forcast
    @tvshows = Tvshow.where("tvr_next_episode_date > 0").sort_by(&:tvr_next_episode_date)
    render :index
  end

  def index
    @tvshows = Tvshow.all.sort_by(&:ttdb_show_title)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tvshows }
    end
  end

  # GET /tvshows/1
  # GET /tvshows/1.json
  def show
    @tvshow = Tvshow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tvshow }
    end
  end

  # GET /tvshows/new
  # GET /tvshows/new.json
  def new
    @tvshow = Tvshow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tvshow }
    end
  end

  # GET /tvshows/1/edit
  def edit
    @tvshow = Tvshow.find(params[:id])
  end

  # POST /tvshows
  # POST /tvshows.json
  def create
    @tvshow = Tvshow.new(params[:tvshow])

    respond_to do |format|
      if @tvshow.save
        format.html { redirect_to @tvshow, notice: 'Tvshow was successfully created.' }
        format.json { render json: @tvshow, status: :created, location: @tvshow }
      else
        format.html { render action: "new" }
        format.json { render json: @tvshow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tvshows/1
  # PUT /tvshows/1.json
  def update
    @tvshow = Tvshow.find(params[:id])

    respond_to do |format|
      if @tvshow.update_attributes(params[:tvshow])
        format.html { redirect_to @tvshow, notice: 'Tvshow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tvshow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tvshows/1
  # DELETE /tvshows/1.json
  def destroy
    @tvshow = Tvshow.find(params[:id])
    @tvshow.destroy

    respond_to do |format|
      format.html { redirect_to tvshows_url }
      format.json { head :no_content }
    end
  end
end
