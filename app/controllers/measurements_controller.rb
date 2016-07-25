class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  def download
  end

  # GET /measurements
  # GET /measurements.json
  def index_slickgrid_m
    @measurements = Measurement.all
    @h_projects = {}   
    if @user
#      if admin?
#        @measurements = Measurement.all
#      else
#        @measurements = Measurement.find(:all, 
#                                         :select => "sample_id, measurements.*", 
#                                         :joins => "join measurements_samples on (measurements.id = measurement_id)", 
#                                         :conditions => { :user_id => @user.id})
#      end
      if params[:project_key]
        @project = Project.find_by_key(params[:project_key])
        @h_projects[@project.id]=@project
        @exp = Exp.find(params[:exp_id]) if params[:exp_id]
        exps = @project.exps
        exps = [@exp] if params[:exp_id] and exps.include?(@exp)
        @samples = Sample.where(:exp_id => exps.map{|e| e.id}).all
        h_condition = (params[:sample_id]) ? { :measurements_samples => {:sample_id =>params[:sample_id]}} :  {}
        @measurements = Measurement.joins("join measurements_samples on (measurements.id = measurement_id)").where(h_condition).select("sample_id, measurements.*").all 
                                         
      else
        @projects = Project.where(:user_id => @user.id).all
#        @project.map{|p| @h_projects[p.id]=p}
        @samples = Sample.joins(:project).where(:projects => {:user_id => @user.id})
        @measurements = Measurement.find(:all, 
                                         :select => "sample_id, measurements.*", 
                                         :joins => "join measurements_samples on (measurements.id = measurement_id)", 
                                         :conditions => { :measurements_samples => {:sample_id => @samples.map{|s| s.id}}})
      end
    end

    respond_to do |format|
      format.html { # index.html.erb
            render :layout => false if params[:layout].to_i == 0
        }
      format.json { render json: @measurements }
    end
  end

  # GET /measurements/1
  # GET /measurements/1.json
  def show
  end

  # GET /measurements/new
  def new
    @measurement = Measurement.new
  end

  # GET /measurements/1/edit
  def edit
  end

  # POST /measurements
  # POST /measurements.json
  def create
    @measurement = Measurement.new(measurement_params)

    respond_to do |format|
      if @measurement.save
        format.html { redirect_to @measurement, notice: 'Measurement was successfully created.' }
        format.json { render :show, status: :created, location: @measurement }
      else
        format.html { render :new }
        format.json { render json: @measurement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /measurements/1
  # PATCH/PUT /measurements/1.json
  def update
    respond_to do |format|
      if @measurement.update(measurement_params)
        format.html { redirect_to @measurement, notice: 'Measurement was successfully updated.' }
        format.json { render :show, status: :ok, location: @measurement }
      else
        format.html { render :edit }
        format.json { render json: @measurement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measurements/1
  # DELETE /measurements/1.json
  def destroy
    @measurement.destroy
    respond_to do |format|
      format.html { redirect_to measurements_url, notice: 'Measurement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measurement
      @measurement = Measurement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measurement_params
      params[:measurement]
    end
end
