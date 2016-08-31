require 'fileutils'
class FusController < ApplicationController
  before_action :set_fu, only: [:show, :edit, :update, :destroy, :upload]

  def upload url
    # save file
    lab = Lab.find(session[:lab_id])
    folder = @measurement.raw ? "/raw" : "/processed"
    lab_upload_dir = APP_CONFIG[:upload_dir] + '/' + lab.name
    upload_dir = APP_CONFIG[:upload_dir] + '/' + lab.name + folder
    logger.debug('UPLOAD: ' + upload_dir.to_s)
    # upload file to tmp folder, copy to archive with sha2 name
    # and delete from tmp folder
    tmp_upload_dir = APP_CONFIG[:tmp_upload_dir] + '/' + lab.name
    Dir.mkdir(tmp_upload_dir) if !Dir.exists?(tmp_upload_dir)

    if !Dir.exists?(lab_upload_dir)
      Dir.mkdir(lab_upload_dir) 
      Dir.mkdir(lab_upload_dir + '/raw')
      Dir.mkdir(lab_upload_dir + '/processed')
    end
    # filename is in the parameters
    # original_filename = url.gsub('&', '_').gsub(':', '_').gsub('/', '_').gsub('?', '').gsub('\\', '')
    tmp_upload_path = tmp_upload_dir + '/' + @fu.filename
    download_cmd = "wget -O #{upload_path} '#{url}'"
    `#{download_cmd}`

    sha2 = Digest::SHA2.file(tmp_upload_path).hexdigest
    FileUtils.move tmp_upload_path, (upload_dir + '/'+ sha2)
    File.delete(tmp_upload_path)
    @fu.update(:sha1 => sha2, :path => upload_dir)
    # File.symlink (upload_dir + sha2), (file_path)
  end

  # GET /fus
  # GET /fus.json
  def index
    @fus = Fu.all
  end

  # GET /fus/1
  # GET /fus/1.json
  def show
  end

  # GET /fus/new
  def new
    @fu = Fu.new
  end

  # GET /fus/1/edit
  def edit
  end

  # POST /fus
  # POST /fus.json
  def create
    logger.debug('FU CREATE')
    @fu = Fu.new(fu_params)
    respond_to do |format|
      if @fu.save
        @fu.run_upload_job
        format.html { redirect_to @fu, notice: 'Fu was successfully created.' }
        format.json { render :show, status: :created, location: @fu }
      else
        format.html { render :new }
        format.json { render json: @fu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fus/1
  # PATCH/PUT /fus/1.json
  def update
    respond_to do |format|
      if @fu.update(fu_params)
        format.html { redirect_to @fu, notice: 'Fu was successfully updated.' }
        format.json { render :show, status: :ok, location: @fu }
      else
        format.html { render :edit }
        format.json { render json: @fu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fus/1
  # DELETE /fus/1.json
  def destroy
    @fu.destroy
    respond_to do |format|
      format.html { redirect_to fus_url, notice: 'Fu was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fu
      @fu = Fu.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fu_params
      params[:fu]
    end
end
