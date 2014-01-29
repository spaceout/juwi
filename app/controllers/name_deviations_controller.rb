class NameDeviationsController < ApplicationController
  # GET /name_deviations
  # GET /name_deviations.json
  def index
    @tvshow = Tvshow.find(params[:tvshow_id])
    @name_deviations = @tvshow.name_deviation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @name_deviations }
    end
  end

  # GET /name_deviations/1
  # GET /name_deviations/1.json
  def show
    @name_deviation = NameDeviation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @name_deviation }
    end
  end

  # GET /name_deviations/new
  # GET /name_deviations/new.json
  def new
    @name_deviation = NameDeviation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @name_deviation }
    end
  end

  # GET /name_deviations/1/edit
  def edit
    @name_deviation = NameDeviation.find(params[:id])
  end

  # POST /name_deviations
  # POST /name_deviations.json
  def create
    @name_deviation = NameDeviation.new(params[:name_deviation])

    respond_to do |format|
      if @name_deviation.save
        format.html { redirect_to @name_deviation, notice: 'Name deviation was successfully created.' }
        format.json { render json: @name_deviation, status: :created, location: @name_deviation }
      else
        format.html { render action: "new" }
        format.json { render json: @name_deviation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /name_deviations/1
  # PUT /name_deviations/1.json
  def update
    @name_deviation = NameDeviation.find(params[:id])

    respond_to do |format|
      if @name_deviation.update_attributes(params[:name_deviation])
        format.html { redirect_to @name_deviation, notice: 'Name deviation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @name_deviation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /name_deviations/1
  # DELETE /name_deviations/1.json
  def destroy
    @name_deviation = NameDeviation.find(params[:id])
    @name_deviation.destroy

    respond_to do |format|
      format.html { redirect_to name_deviations_url }
      format.json { head :no_content }
    end
  end
end
