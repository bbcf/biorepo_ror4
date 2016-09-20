class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  def download
  end

  def index
    @measurements = Measurement.all
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
        samples = Sample.where(:exp_id => exps.map{|e| e.id}).first
#    @measurements = Measurement.all
        @measurements = samples.measurements
      else
        @projects = Project.where(:user_id => @user.id).all
        @projects.map{|p| @h_projects[p.id]=p}
        samples = Sample.joins(:project).where(:projects => {:user_id => @user.id}).first
  #  @measurements = Measurement.all
        @measurements = samples.measurements
      end
      #      end
      
      respond_to do |format|
        format.html {
          render :layout => false if params[:layout] == '0'
        }
      end
    end
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
        @measurements = Measurement.joins("join measurements_samples on (measurements.id = measurement_id) left join fus on fu_id = fus.id").where(h_condition).select("sample_id, fus.filename as filename, fus.url_path as url_path, fus.path as path, fus.status as status, fus,sha1 as sha1, measurements.*").all 
   #     @measurements = Measurement.joins("join measurements_samples on (measurements.id = measurement_id)").where(h_condition).select("sample_id, measurements.*").all 
 
        @SlickGridMeasurementData = [] 
        # get attributes for this exp_type and owner = 'measurement'
        h_condition = (exp_type_id) ? {:attrs_exp_types => {:exp_type_id => exp_type_id}, :owner => 'measurement'} : {:owner => 'measurement'}
        @attrs = Attr.joins("join attrs_exp_types on (attrs.id = attr_id)").where(h_condition).select("exp_type_id, attrs.*").all 

        h_columns = {}
        @measurements.each do |m|
# if could do left cross join with attrs - attr_values (even empty) 
#            h_avcondition = {:attr_values_measurements => {:measurement_id => m.id}, :attr_id => @attrs.map{|a| a.id}}
#            @attr_values = AttrValue.joins("join attr_values_measurements on (attr_values.id = attr_value_id) join attrs on (attrs.id = attr_values.attr_id)").where(h_avcondition).select("attrs.name as aname, measurement_id as mid, attr_values.*").all
#            @attr_values.each do |av|
#                h_av[av.aname] = av.name
#                h_columns[av.attr_id] = {:id => av.attr_id, :name => av.aname, :field => av.aname}
#            end
            # get attr_values for each measurement of this sample of this exp_type
            h_av = {}
            logger.debug('INDEX SG MEASUREMENTS: ' + m.id.to_s + ', raw = ' + m.raw.to_s + ', desc = ' + m.description.to_s)
            @attrs.each do |a|
               logger.debug("ATTR.name = " + a.name + ' ' + a.widget_id.to_s)
               h_avcondition = {:attr_values_measurements => {:measurement_id => m.id}, :attr_id => a.id}
               av = AttrValue.joins("join attr_values_measurements on (attr_values.id = attr_value_id)").where(h_avcondition).select("attr_values.*")
               (av.count > 0) ? (h_av[a.name] = av.first.name) : h_av[a.name] = ''
            end
            # display date nicely
            h_av[:date] = display_date(m.created_at.localtime)
            @SlickGridMeasurementData.push(m.attributes.merge(h_av.merge({:exp_id => params[:exp_id]})))
        end                                 
        # collect attr_values as options for SlickGrid.SelectCelEditor
        @attrs.each do |a|
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

  # POST
  def save_batch
    logger.debug('SAVE_MEASUREMENTS: ' + params.to_s)
    measurements_data = params[:_json]
    exp_id = params[:exp_id]
    exp_type_id = Exp.find(exp_id).exp_type_id
    @sample = Sample.find(params[:sample_id]) if params[:sample_id]
    h_res={}
    
    measurements_data.each do |row|
    #exp_type_id = Exp.find(row[:exp_id]).exp_type_id 
        if row[:id] and row[:id] > 0
            @measurement = Measurement.find(row[:id]) 
        end
        # measurement already exists
        if @measurement
             @measurement.update_attributes(:name => row[:name], :raw => row[:raw], :public => row[:public], :description => row[:description])
             logger.debug('EXP: = ' + exp_type_id.to_s)
        # new sample
        else
             logger.debug('NEW M: = ')
             @measurement = Measurement.new(:name => row[:name], :user_id => session[:user_id], :raw => row[:raw], :public => row[:public], :description => row[:description])
             @measurement.save!
             @sample.measurements << @measurement
             # save files only if url_path is present
             if row[:url_path]
                new_file_name = row[:filename] ? row[:filename] : @measurement.name
                file = Fu.new(:filename => new_file_name, :url_path => row[:url_path])
                # file = Fu.new(:filename => @measurement.name, :url_path => row[:filename])
                if file.save
                    @measurement.update(:fu_id => file.id)
                    file.run_upload_job row[:url_path], session[:lab_id], @measurement.raw
                end
             end
        end
        update_attrs(row, exp_type_id)
        @measurement = nil
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: h_res  }
    end
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

  def update_attrs(row, exp_type_id)
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
              if !@attr_value_new and a.widget_id == 5

              else
                if !@attr_value_new and a.widget_id !=5 # and !row[a.name].empty?
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
      end
  end

  # DELETE /measurements/1
  # DELETE /measurements/1.json
  
  def delete_batch
    logger.debug('DELETE_MEASUREMENTS: ' + params.to_s)
    # list of ids to delete
    m_data = params[:_json]
    res={:error => ''}
    error = false
    if !m_data or !m_data.size 
        res[:error] = 'Select measurements to delete.'
    else
        fus_measurements = Measurement.joins("join fus on (fu_id = fus.id)").where({:id => m_data}).select("measurements.id as mid, fus.id as fid").all
        h = Hash[*fus_measurements.map {|fm| [fm.mid, fm.fid]}.flatten]
        m_data.each do |id|
           logger.debug('h: ' + h[id].to_s + ', id: ' + id.to_s)
           @measurement = Measurement.find(id) if id and id > 0
           if @measurement
                if h[id]
                    fu = Fu.find(h[id])
                    # !!!!!!!!!!!!!!!!!!!!!!!!
                    # check if I really want to delete the file
                    fu.destroy
                    #res[:error] += id.to_s
                    #error = true
                end
                @measurement.destroy
           end
        end
        res[:error] = 'Could not delete measurements ' + res[:error] if error
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => res  }
    end
  end

  def destroy
    @measurement.destroy
    respond_to do |format|
      format.html { redirect_to measurements_url, notice: 'Measurement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def download_batch
    logger.debug('DOWNLOAD_MEASUREMENTS: ' + params.to_s)
    # list of ids to delete
    m_data = params[:_json]
    res={:error => ''}
    if !m_data or !m_data.size 
        res[:error] = 'Select measurements to download.'
    else
        fus = Measurement.joins("join fus on measurements.fu_id = fus.id").where({:id => m_data}).select("fus.*")
        if (!fus.count)
            res[:error] = 'Could not download files: no files for selected measurements '
        else
            time = Time.now
            user = User.find(session[:user_id])
            sample = Sample.joins('join measurements_samples on measurements_samples.sample_id = samples.id').where(:measurements_samples => {:measurement_id => m_data}).select("samples.*").first
            date = time.strftime("%Y%m%d")
            zipfile_name = date + '_' + user.name + '_' + sample.name + '.zip'
            dl = Download.new(:name => zipfile_name, :user_id => session[:user_id], :lab_id => session[:lab_id])
            if dl.save! 
                # change this
                # h_files = Hash[*fus.map {|f| [f.sha1, f.path + '/' + f.filename]}.flatten]
                h_files = Hash[*fus.map {|f| [f.path + '/' + f.sha1, f.filename]}.flatten]
                dl.run_download_job h_files, zipfile_name
            end
        end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => res  }
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
    
    def sample_params
      params[:sample]
    end

    def display_date(c)
        n = Time.now
        html = "" #<table class='display_date'><tr><td class='day'>"
        if n.day == c.day and n.month == c.month and n.year == c.year
            html += "Today"
#    elsif n.day == c.day + 1 and n.month == c.month and n.year == c.year
#      html += "Yesterday"
        else
            html += "#{c.year}.#{"0" if c.month < 10}#{c.month}.#{"0" if c.day < 10}#{c.day}"
        end
        html += " at #{"0" if c.hour < 10}#{c.hour}:#{"0" if c.min < 10}#{c.min}:#{"0" if c.sec < 10}#{c.sec}" #</td></tr></table>"
    end
end
