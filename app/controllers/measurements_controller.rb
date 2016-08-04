class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  def download
  end

  # GET /measurements
  # GET /measurements.json
  def index_slickgrid_m
    @measurements = Measurement.all
    if @user
      if params[:project_key]
        @project = Project.find_by_key(params[:project_key])
        @exp = Exp.find(params[:exp_id]) if params[:exp_id]
        exp_type_id = @exp.exp_type_id if @exp
        
        exps = @project.exps
        exps = [@exp] if params[:exp_id] and exps.include?(@exp)
        
        h_condition = (params[:sample_id]) ? { :measurements_samples => {:sample_id =>params[:sample_id]}} :  {}
        @measurements = Measurement.joins("join measurements_samples on (measurements.id = measurement_id)").where(h_condition).select("sample_id, measurements.*").all 
 
        @SlickGridMeasurementData = [] 
        # get attributes for this exp_type and owner = 'measurement'
        h_condition = (exp_type_id) ? {:attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'measurement'} : {:owner => 'measurement'}
        @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("exp_type_id, attrs.*").all 

        h_columns = {}
        @measurements.each do |m| 
            # get attr_values for each measurement of this sample of this exp_type
#            h_avcondition = {:attr_values_measurements => {:measurement_id => m.id}, :attr_id => @attrs.map{|a| a.id}}
#            @attr_values = AttrValue.joins("join attr_values_measurements on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avcondition).select("attrs.name as aname, measurement_id as mid, attr_values.*").all
            h_av = {}
            @attrs.each do |a|
               logger.debug("ATTR.name = " + a.name + ' ' + a.widget_id.to_s)
               h_avcondition = {:attr_values_measurements => {:measurement_id => m.id}, :attr_id => a.id}
               av = AttrValue.joins("join attr_values_measurements on (attr_values.id = attr_value_id)").where(h_avcondition).select("attr_values.*")
               (av.count > 0) ? (h_av[a.name] = av.first.name) : h_av[a.name] = ''
               # collect attr_values as options for SlickGrid.SelectCelEditor
               options = ""
               if a.widget_id == 5
                    av_options = AttrValue.where({:attr_id => a.id}).order(:name)
                    av_options.each do |avo|
                        options = options + "," + avo.name
                    end
               end
               h_columns[a.id] = {:id => a.id, :name => a.name, :field => a.name, :widget => a.widget_id, :options => options}
            end
#            @attr_values.each do |av|
#                h_av[av.aname] = av.name
#                h_columns[av.attr_id] = {:id => av.attr_id, :name => av.aname, :field => av.aname}
#            end
            @SlickGridMeasurementData.push(m.attributes.merge(h_av.merge({:exp_id => params[:exp_id]})))
        end                                 
        @list_columns_m = h_columns.values.sort{|a, b| a[:id] <=> b[:id]}
      else
        @projects = Project.where(:user_id => @user.id).all
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
