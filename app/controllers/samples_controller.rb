class SamplesController < ApplicationController
  before_action :set_sample, only: [:show, :edit, :update, :destroy]

  # GET /samples
  # GET /samples.json

  def test
  end

  def index
    @samples = Sample.all
    @h_projects = {}
    
    if @user
      #      if admin?
      #        @samples = Sample.all
      #        Project.all.map{|p| @h_projects[p.id]=p}
      #      else
      if params[:project_key]
        @project = Project.find_by_key(params[:project_key])
        @h_projects[@project.id]=@project
        @exp = Exp.find(params[:exp_id]) if params[:exp_id]
        exps = @project.exps
        exps = [@exp] if params[:exp_id] and exps.include?(@exp)
        @samples = Sample.where(:exp_id => exps.map{|e| e.id}).all
      else
        @projects = Project.where(:user_id => @user.id).all
        @project.map{|p| @h_projects[p.id]=p}
        @samples = Sample.joins(:project).where(:projects => {:user_id => @user.id})
      end
      #      end
      
      respond_to do |format|
        format.html {
          render :layout => false if params[:layout].to_i == 0
        }
      end
    end
  end
  
  def index_slickgrid
 #   @samples = Sample.all
 #   @h_projects = {}

    if @user
        if params[:project_key]
          @project = Project.find_by_key(params[:project_key])
   #       @h_projects[@project.id]=@project
          @exp = Exp.find(params[:exp_id]) if params[:exp_id]
          exps = @project.exps
          exps = [@exp] if params[:exp_id] and exps.include?(@exp)
          @samples = Sample.where(:exp_id => exps.map{|e| e.id}).all

    #      @h_attr_values = {}
          # [{:id , :name , :description, <attr_values> }, {}, {}]
          @SlickGridSampleData = [] 
          exp_type_id = @exp.exp_type_id if @exp
          # get attributes for this experiment type
          h_condition = (exp_type_id) ? { :attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'sample'} :  {:owner => 'sample'}
          @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("exp_type_id, attrs.*").all
          @attrs.each do |a|
            logger.debug('S ATTR: ' + a.name.to_s + ' ' + a.owner.to_s)
          end
          # hash of attributes for samples 
          h_columns = {}
          @samples.each do |s|
            # get attribute values for each sample of this experiment type
            h_avcondition = {:attr_values_samples => {:sample_id => s.id}, :attr_id => @attrs.map{|a| a.id}}
            @attr_values = AttrValue.joins("join attr_values_samples on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avcondition).select("attrs.name as aname, sample_id as sid, attr_values.*").all
            # ?????????????????????
            @h_av = {}
            @attr_values.each do |av|
                # hash of key: attrs.name value: attr_values.name for SlickGrid data
                @h_av[av.aname] = av.name
                # make a hash - key: attr_id, value: hash of data for SlickGrid columns
                h_columns[av.attr_id] = {:id => av.attr_id, :name => av.aname, :field => av.aname}
            end
            # merge samples.* with {attrs: attr_values} for SlickGrid data
            @SlickGridSampleData.push( s.attributes.merge(@h_av))
          end
          # sort attributes by id and get list of them
          @list_columns = h_columns.values.sort{|a, b| a[:id] <=> b[:id]}
        else
   #       @projects = Project.where(:user_id => @user.id).all
   #       @project.map{|p| @h_projects[p.id]=p}
          @samples = Sample.joins(:project).where(:projects => {:user_id => @user.id})
        end
#      end
      
      respond_to do |format|
        format.html {
          render :layout => false if params[:layout].to_i == 0
        }
      end
    end
  end

  # GET /samples/1
  # GET /samples/1.json
  def show
  end

  # GET /samples/new
  def new
    @sample = Sample.new
  end

  # GET /samples/1/edit
  def edit
  end

  # POST /samples
  # POST /samples.json
  def create
    @sample = Sample.new(sample_params)

    respond_to do |format|
      if @sample.save
        format.html { redirect_to @sample, notice: 'Sample was successfully created.' }
        format.json { render :show, status: :created, location: @sample }
      else
        format.html { render :new }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /samples/1
  # PATCH/PUT /samples/1.json
  def update
    respond_to do |format|
      if @sample.update(sample_params)
        format.html { redirect_to @sample, notice: 'Sample was successfully updated.' }
        format.json { render :show, status: :ok, location: @sample }
      else
        format.html { render :edit }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy
    @sample.destroy
    respond_to do |format|
      format.html { redirect_to samples_url, notice: 'Sample was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sample
      @sample = Sample.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sample_params
      params[:sample]
    end
end
