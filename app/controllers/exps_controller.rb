class ExpsController < ApplicationController
  before_action :set_exp, only: [:show, :edit, :update, :destroy]


  def batch_upload_form
  end
  
  def batch_upload
  end


  # GET /exps
  # GET /exps.json
  def index
    if params[:project_key]
      @project = Project.find_by_key(params[:project_key])
      @exps = @project.exps
    else
      @exps = Exp.all
    end
    
    respond_to do |format|
      format.html {
          render :layout => false if params[:layout].to_i == 0
      }
    end
    
  end

  # GET /exps/1
  # GET /exps/1.json
  def show
  end

  # GET /exps/new
  def new
    @exp = Exp.new

    respond_to do |format|
      format.html {
        render :layout => false if params[:layout].to_i == 0
      }
    end
    
  end

  # GET /exps/1/edit
  def edit
  end

  # POST /exps
  # POST /exps.json
  def create
    logger.debug('EXP CREATE PARAMS: ' + params.to_s)
    if params[:project_key]
      @project =  Project.find_by_key(params[:project_key])
    end
    @exp = Exp.new(exp_params)
    @exp.project_id = @project.id
    @exp.user_id = session[:user_id]

    respond_to do |format|
      if @exp.save
        @project.exps << @exp if !@project.exps.include?(@exp) 
        format.html { redirect_to action: :index, project_key: @project.key, layout: 0, notice: 'Exp was successfully created.' }
        format.json { render :show, status: :created, location: @exp }
      else
        format.html { render :new }
        format.json { render json: @exp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exps/1
  # PATCH/PUT /exps/1.json
  def update
    respond_to do |format|
      if @exp.update(exp_params)
        format.html { redirect_to @exp, notice: 'Exp was successfully updated.' }
        format.json { render :show, status: :ok, location: @exp }
      else
        format.html { render :edit }
        format.json { render json: @exp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exps/1
  # DELETE /exps/1.json
  def destroy
    res = {:error => ''}
    if ( Sample.exists?(:exp_id => @exp.id))
        res = {:error => 'cannot delete experiment with samples.'}
    else
        @exp.destroy
    end
    respond_to do |format|
      format.html { redirect_to exps_url, notice: 'Exp was successfully destroyed.' }
      format.json { render :json => res}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exp
      @exp = Exp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exp_params
      params.require(:exp).permit(:name, :exp_type_id )
    end
end
