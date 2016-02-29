class MeasurementRelsController < ApplicationController
  before_action :set_measurement_rel, only: [:show, :edit, :update, :destroy]

  # GET /measurement_rels
  # GET /measurement_rels.json
  def index
    @measurement_rels = MeasurementRel.all
  end

  # GET /measurement_rels/1
  # GET /measurement_rels/1.json
  def show
  end

  # GET /measurement_rels/new
  def new
    @measurement_rel = MeasurementRel.new
  end

  # GET /measurement_rels/1/edit
  def edit
  end

  # POST /measurement_rels
  # POST /measurement_rels.json
  def create
    @measurement_rel = MeasurementRel.new(measurement_rel_params)

    respond_to do |format|
      if @measurement_rel.save
        format.html { redirect_to @measurement_rel, notice: 'Measurement rel was successfully created.' }
        format.json { render :show, status: :created, location: @measurement_rel }
      else
        format.html { render :new }
        format.json { render json: @measurement_rel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /measurement_rels/1
  # PATCH/PUT /measurement_rels/1.json
  def update
    respond_to do |format|
      if @measurement_rel.update(measurement_rel_params)
        format.html { redirect_to @measurement_rel, notice: 'Measurement rel was successfully updated.' }
        format.json { render :show, status: :ok, location: @measurement_rel }
      else
        format.html { render :edit }
        format.json { render json: @measurement_rel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measurement_rels/1
  # DELETE /measurement_rels/1.json
  def destroy
    @measurement_rel.destroy
    respond_to do |format|
      format.html { redirect_to measurement_rels_url, notice: 'Measurement rel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measurement_rel
      @measurement_rel = MeasurementRel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measurement_rel_params
      params[:measurement_rel]
    end
end
