class ExpTypesController < ApplicationController
  before_action :set_exp_type, only: [:show, :edit, :update, :destroy]

  # GET /exp_types
  # GET /exp_types.json
  def index
    @exp_types = ExpType.all
  end

  # GET /exp_types/1
  # GET /exp_types/1.json
  def show
  end

  # GET /exp_types/new
  def new
    @exp_type = ExpType.new
  end

  # GET /exp_types/1/edit
  def edit
  end

  # POST /exp_types
  # POST /exp_types.json
  def create
    @exp_type = ExpType.new(exp_type_params)

    respond_to do |format|
      if @exp_type.save
        format.html { redirect_to @exp_type, notice: 'Exp type was successfully created.' }
        format.json { render :show, status: :created, location: @exp_type }
      else
        format.html { render :new }
        format.json { render json: @exp_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exp_types/1
  # PATCH/PUT /exp_types/1.json
  def update
    respond_to do |format|
      if @exp_type.update(exp_type_params)
        format.html { redirect_to @exp_type, notice: 'Exp type was successfully updated.' }
        format.json { render :show, status: :ok, location: @exp_type }
      else
        format.html { render :edit }
        format.json { render json: @exp_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exp_types/1
  # DELETE /exp_types/1.json
  def destroy
    @exp_type.destroy
    respond_to do |format|
      format.html { redirect_to exp_types_url, notice: 'Exp type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exp_type
      @exp_type = ExpType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exp_type_params
      params[:exp_type]
    end
end
