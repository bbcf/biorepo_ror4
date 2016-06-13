class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
    @h_users = {}
    User.all.map{|u| @h_users[u.id]=u}
    
    @projects = []

    if @user
      if admin?
        @projects = Project.all
      else
        #@projects = Project.find(:all, :conditions => {:user_id => @user.id})
        @projects = Project.where(:user_id => @user.id)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new    
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    logger.debug('PARAMS:'+ params.to_s)
    @project = Project.new(project_params)
   # @project.user_id = @user.id
#    @project = Project.new(:user_id => session[:user_id], :name => params[:project_name], :description => params[:description])
   
    @project.key = create_key(Project, 6)
    @project.user_id = @user.id

    respond_to do |format|
      if @project.save
        format.html { redirect_to edit_project_path(@project.key), notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to edit_project_path(@project.key), notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find_by_key(params[:key])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
        params.require(:project).permit(:name, :description)
        #params[:project]
    end
end
