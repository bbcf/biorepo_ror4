class FusController < ApplicationController
  before_action :set_fu, only: [:show, :edit, :update, :destroy]

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
    @fu = Fu.new(fu_params)

    respond_to do |format|
      if @fu.save
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
