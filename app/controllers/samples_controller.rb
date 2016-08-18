class SamplesController < ApplicationController
  before_action :set_sample, only: [:show, :edit, :update, :update_attrs, :destroy]

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
        @projects.map{|p| @h_projects[p.id]=p}
        @samples = Sample.joins(:project).where(:projects => {:user_id => @user.id})
      end
      #      end
      
      respond_to do |format|
        format.html {
          render :layout => false if params[:layout] == '0'
        }
      end
    end
  end
  
  def index_slickgrid
    if @user
        if params[:project_key]
          @project = Project.find_by_key(params[:project_key])
          @exp = Exp.find(params[:exp_id]) if params[:exp_id]
          exps = @project.exps
          exps = [@exp] if params[:exp_id] and exps.include?(@exp)
          @samples = Sample.where(:exp_id => exps.map{|e| e.id}).all

          # [{:id , :name , :description, <attr_values> }, {}, {}]
          @SlickGridSampleData = [] 
          exp_type_id = @exp.exp_type_id if @exp
          # get attributes for this experiment type
          h_condition = (exp_type_id) ? { :attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'sample'} :  {:owner => 'sample'}
          @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("exp_type_id, attrs.*").all
          # hash of attributes for samples 
          h_columns = {}
          @samples.each do |s|
#            h_avcondition = {:attr_values_samples => {:sample_id => s.id}, :attr_id => @attrs.map{|a| a.id}}
#            @attr_values = AttrValue.joins("join attr_values_samples on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avcondition).select("attrs.name as aname, sample_id as sid, attr_values.*").all
#            @attr_values.each do |av|
#                # hash of key: attrs.name value: attr_values.name for SlickGrid data
#                @h_av[av.aname] = av.name
#                # make a hash - key: attr_id, value: hash of data for SlickGrid columns
#                h_columns[av.attr_id] = {:id => av.attr_id, :name => av.aname, :field => av.aname}
#            end
            # get attribute values for each sample of this experiment type
            h_av = {}
            @attrs.each do |a|
               h_avcondition = {:attr_values_samples => {:sample_id => s.id}, :attr_id => a.id}
               av = AttrValue.joins("join attr_values_samples on (attr_values.id = attr_value_id)").where(h_avcondition).select("attr_values.*")
               (av.count > 0) ? h_av[a.name] = av.first.name : h_av[a.name] = ''
            end
            # display date nicely
            h_av[:date] = display_date(s.created_at.localtime)
            # merge samples.* with {attrs: attr_values} for SlickGrid data
            @SlickGridSampleData.push( s.attributes.merge(h_av))
          end
          # fill data for columns for SlickGrid
          @attrs.each do |a|
             options = ""
             if a.widget_id == 5
                  av_options = AttrValue.where({:attr_id => a.id}).order(:name)
                  av_options.each do |avo|
                      options = options + "," + avo.name
                  end
             end
             h_columns[a.id] = {:id => a.id, :name => a.name, :field => a.name, :widget => a.widget_id, :options => options}
          end
          # sort attributes by id and get list of them
          @list_columns = h_columns.values.sort{|a, b| a[:id] <=> b[:id]}
        else
          @samples = Sample.joins(:project).where(:projects => {:user_id => @user.id})
        end
      
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

# not used now as by batch samples are only added to the table
 def batch_new_deprecated
    if params[:project_key]
        @project = Project.find_by_key(params[:project_key])
        @exp = Exp.find(params[:exp_id]) if params[:exp_id]
        logger.debug('BATCH_NEW = '+params[:samples_data].to_s) 
        
        samples_data = JSON.parse(params[:samples_data])
        logger.debug('BATCH_NEW = '+ samples_data.to_s) 
        nber_new_samples = params[:nber_new_samples]
        for i in 1..nber_new_samples.to_i
            sample_attrs = (samples_data.length >= nber_new_samples.to_i) ? samples_data[i - 1] : {}
            logger.debug(sample_attrs["description"].to_s) 
            @sample = Sample.new(:name => "sample_" + i.to_s, :project_id => @project.id, :exp_id => params[:exp_id], :description => sample_attrs["description"])
            @sample.save!  
        end
        h_res = {} 
        respond_to do |format|
            format.html # index.html.erb
            format.json { render json: h_res  }
        end    
    #            render :layout => false if params[:layout].to_i == 0
    end
  end

  # POST
  def save_batch
    logger.debug('SAVE_SAMPLES: ' + params.to_s)
    samples_data = params[:_json]
    exp_id = params[:exp_id]
    exp_type_id = Exp.find(exp_id).exp_type_id 
    project_key = params[:project_key]
    @project = Project.find_by_key(project_key)
    h_res={}
    
    samples_data.each do |row|
           @sample = Sample.find(row[:id]) if row[:id] and row[:id] > 0
           # sample already exists
           if @sample
                @sample.update_attributes(:name => row[:name], :protocole => row[:protocole], :description => row[:description])
                logger.debug('FOUND SAMPLE: ' + @sample.id.to_s)
           # new sample
           else
                @sample = Sample.new(:name => row[:name], :project_id => @project.id, :exp_id => exp_id, :protocole => row[:protocole], :description => row[:description])
                @sample.save!
           end
           update_attrs(row, exp_type_id) 
           @sample = nil
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: h_res  }
    end
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


  def update_attrs(row, exp_type_id) 

     # get attributes for this experiment type
     # can be done only once
     h_condition = (exp_type_id) ? { :attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'sample'} :  {:owner => 'sample'}
     @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("attrs.*").all                
     @attrs.each do |a|
         if row[a.name]
#         logger.debug('ATTR: ' + a.name.to_s)
         # select old atr_value for this sample
         h_avo_condition = {:attr_values_samples => {:sample_id => row[:id]}, :attr_id => a.id}
         @attr_value_old = AttrValue.joins("join attr_values_samples on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avo_condition).select("attrs.name as aname, attr_values.*").first # all
#         logger.debug('sid = ' + row[:id].to_s + '; avid = ' + @attr_value_old.id.to_s + '; avname = ' + @attr_value_old.name.to_s) if @attr_value_old
         # if attr_value was deleted in SlickGrid
         if row[a.name].empty?
#             logger.debug('DELETE old av and empty new av: ')
             @sample.attr_values.delete(@attr_value_old) if @attr_value_old
         # there is a new attr_value in SlickGrid
         else
             # select new attr_value from SlickGrid
             attr_value_name = row[a.name]
             h_avn_condition = { :attr_id => a.id, :name => row[a.name]}
             @attr_value_new = AttrValue.joins(" join attrs on (attrs.id = attr_values.attr_id)").where(h_avn_condition).select("attrs.name as aname, attr_values.*").first # all
             # if not existing attr_value - save in DB
             if !@attr_value_new # and !row[a.name].empty?
#                 logger.debug('ADD new av in DB')
                 @attr_value_new = AttrValue.new(:name => row[a.name], :attr_id => a.id)
                 @attr_value_new.save!
             end
#             logger.debug('NEW avn: ' + @attr_value_new.name.to_s)
             # if attr_value was not changed in SlickGrid do nothing
             if @sample.attr_values.include?(@attr_value_new)
#              logger.debug('NOT changed for  sid = ' + row[:id].to_s + '; aname = '+ @attr_value_new.aname + '; avid = ' + @attr_value_new.id.to_s + '; avname = ' + @attr_value_new.name.to_s)
             else
                 # delete old attr_value in DB
#                 logger.debug('ADD and DELETE')
                 @sample.attr_values.delete(@attr_value_old) if @attr_value_old
                 @sample.attr_values << @attr_value_new
             end
         end
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

    def display_date(c)
        n = Time.now
        html = "" #<table class='display_date'><tr><td class='day'>"
        if n.day == c.day and n.month == c.month and n.year == c.year
            html += "Today"
        else
            html += "#{c.year}.#{"0" if c.month < 10}#{c.month}.#{"0" if c.day < 10}#{c.day}"
        end
        html += " at #{"0" if c.hour < 10}#{c.hour}:#{"0" if c.min < 10}#{c.min}:#{"0" if c.sec < 10}#{c.sec}" #</td></tr></table>"
    end
end

