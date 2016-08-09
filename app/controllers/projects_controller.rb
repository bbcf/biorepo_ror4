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
    logger.debug('EDIT')
  end

  # POST /projects
  # POST /projects.json
  def create
    logger.debug('PARAMS:'+ params.to_s)
    logger.debug('CREATE')
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
        logger.debug('PROJECT_PARAMS: ')
        logger.debug( project_params.to_s)
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

  # POST
  def save_samples
    logger.debug('SAVE_SAMPLES: ' + params.to_s)
    samples_data = params[:_json]
    h_res={}
    
    samples_data.each do |row|
           @sample = Sample.find(row[:id]) if row[:id]
           # VALIDATE PARAMETERS!!!!!!!!
           # sample already exists
           if @sample
                @sample.update_attributes(:name => row[:name], :protocole => row[:protocole], :description => row[:description])
                exp_type_id = Exp.find(row[:exp_id]).exp_type_id 
                logger.debug('EXP: = ' + exp_type_id.to_s)
                # get attributes for this experiment type
                # can be done only once
                h_condition = (exp_type_id) ? { :attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'sample'} :  {:owner => 'sample'}
                @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("attrs.*").all                
                @attrs.each do |a|
                    if row[a.name]
                    logger.debug('ATTR: ' + a.name.to_s)
                    # select old atr_value for this sample
                    h_avo_condition = {:attr_values_samples => {:sample_id => row[:id]}, :attr_id => a.id}
                    @attr_value_old = AttrValue.joins("join attr_values_samples on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avo_condition).select("attrs.name as aname, attr_values.*").first # all
                    logger.debug('sid = ' + row[:id].to_s + '; avid = ' + @attr_value_old.id.to_s + '; avname = ' + @attr_value_old.name.to_s) if @attr_value_old
                    # if attr_value was deleted in SlickGrid
                    if row[a.name].empty?
                        logger.debug('DELETE old av and empty new av: ')
                        @sample.attr_values.delete(@attr_value_old) if @attr_value_old
                    # there is a new attr_value in SlickGrid
                    else
                        # select new attr_value from SlickGrid
                        attr_value_name = row[a.name]
                        h_avn_condition = { :attr_id => a.id, :name => row[a.name]}
                        @attr_value_new = AttrValue.joins(" join attrs on (attrs.id = attr_values.attr_id)").where(h_avn_condition).select("attrs.name as aname, attr_values.*").first # all
                        # if not existing attr_value - save in DB
                        if !@attr_value_new # and !row[a.name].empty?
                            logger.debug('ADD new av in DB')
                            @attr_value_new = AttrValue.new(:name => row[a.name], :attr_id => a.id)
                            @attr_value_new.save!
                        end
                        logger.debug('NEW avn: ' + @attr_value_new.name.to_s)
                        # if attr_value was not changed in SlickGrid do nothing
                        if @sample.attr_values.include?(@attr_value_new)
                            logger.debug('NOT changed for  sid = ' + row[:id].to_s + '; aname = '+ @attr_value_new.aname + '; avid = ' + @attr_value_new.id.to_s + '; avname = ' + @attr_value_new.name.to_s)
                        else
                            # delete old attr_value in DB
                            logger.debug('ADD and DELETE')
                            @sample.attr_values.delete(@attr_value_old) if @attr_value_old
                            @sample.attr_values << @attr_value_new
                        end
                    end
                    end
                end
           # new sample
           else
                Sample.new(:name => row[:name], :project_id => @project.id, :exp_id => row[:exp_id], :protocole => row[:protocole], :description => row[:description])
           end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: h_res  }
    end
  end

  # POST
  def save_measurements
    logger.debug('SAVE_MEASUREMENTS: ' + params.to_s)
    measurements_data = params[:_json]
    h_res={}
    
    measurements_data.each do |row|
           @measurement = Measurement.find(row[:id]) if row[:id]
           # VALIDATE PARAMETERS!!!!!!!!
           # measurement already exists
           if @measurement
                @measurement.update_attributes(:name => row[:name], :raw => row[:raw], :public => row[:public], :description => row[:description])
                exp_type_id = Exp.find(row[:exp_id]).exp_type_id 
                logger.debug('EXP: = ' + exp_type_id.to_s)
                # get attributes for this experiment type
                # can be done only once
                h_condition = (exp_type_id) ? { :attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'measurement'} :  {:owner => 'measurement'}
                @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("attrs.*").all                
                @attrs.each do |a|
                  if row[a.name]
                    logger.debug('M ATTR: ' + a.name.to_s)
                    # select old atr_value for this measurement
                    h_avo_condition = {:attr_values_measurements => {:measurement_id => row[:id]}, :attr_id => a.id}
                    @attr_value_old = AttrValue.joins("join attr_values_measurements on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avo_condition).select("attrs.name as aname, attr_values.*").first # all
                    logger.debug('mid = ' + row[:id].to_s + '; avid = ' + @attr_value_old.id.to_s + '; avname = ' + @attr_value_old.name.to_s) if @attr_value_old
                    # if attr_value was deleted in SlickGrid
                    if row[a.name].empty?
                        logger.debug('DELETE old av and empty new av: ')
                        @measurement.attr_values.delete(@attr_value_old) if @attr_value_old
                    # there is a new attr_value in SlickGrid
                    else
                        # select new attr_value from SlickGrid
                        attr_value_name = row[a.name]
                        h_avn_condition = { :attr_id => a.id, :name => row[a.name]}
                        @attr_value_new = AttrValue.joins(" join attrs on (attrs.id = attr_values.attr_id)").where(h_avn_condition).select("attrs.name as aname, attr_values.*").first # all
                        # if not existing attr_value - save in DB
                        if !@attr_value_new # and !row[a.name].empty?
                            logger.debug('ADD new av in DB')
                            @attr_value_new = AttrValue.new(:name => row[a.name], :attr_id => a.id)
                            @attr_value_new.save!
                        end
                        logger.debug('NEW avn: ' + @attr_value_new.name.to_s)
                        # if attr_value was not changed in SlickGrid do nothing
                        if @measurement.attr_values.include?(@attr_value_new)
                            logger.debug('NOT changed for  sid = ' + row[:id].to_s + '; aname = '+ @attr_value_new.aname + '; avid = ' + @attr_value_new.id.to_s + '; avname = ' + @attr_value_new.name.to_s)
                        else
                            # delete old attr_value in DB
                            logger.debug('ADD and DELETE')
                            @measurement.attr_values.delete(@attr_value_old) if @attr_value_old
                            @measurement.attr_values << @attr_value_new
                        end
                    end
                  end
                end
           # new sample
           else
                Measurement.new(:name => row[:name], :user_id => session[:user_id], :raw => row[:raw], :public => row[:public], :description => row[:description])
           end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: h_res  }
    end
  end
  # POST
  def save_measurements_old
    logger.debug('SAVE_MEASUREMENTS: ' + params.to_s)
    measurements_data = params[:_json]
    h_res={}
    
    measurements_data.each do |row|
           @measurement = Measurement.find(row[:id]) if row[:id]
           # measurement already exists
           # if row[:id]
           # VALIDATE PARAMETERS!!!!!!!!
           if @measurement
                @measurement.update_attributes(:name => row[:name], :raw => row[:raw], :public => row[:public], :description => row[:description])
           # new measurement 
           else
                Measurement.new(:name => row[:name],  :user_id => session[:user_id], :raw => row[:raw], :public => row[:public], :description => row[:description])
           end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: h_res  }
    end

  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find_by_key(params[:key])
      @exps = @project.exps
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
        params.require(:project).permit(:name, :description)
        #params[:project]
    end
end
