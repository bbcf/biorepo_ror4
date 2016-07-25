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
