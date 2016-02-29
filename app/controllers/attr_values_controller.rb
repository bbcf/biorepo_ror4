class AttrValuesController < ApplicationController
  before_action :set_attr_value, only: [:show, :edit, :update, :destroy]

  # GET /attr_values
  # GET /attr_values.json
  def index
    @attr_values = AttrValue.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @attr_values }
    end
  end

  # GET /attr_values/1
  # GET /attr_values/1.json
  def show
 #   @attr_value = AttrValue.find(attr_value__params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attr_value }
    end
  end

  # GET /attr_values/new
  def new
    @attr_value = AttrValue.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attr_value }
    end
  end

  # GET /attr_values/1/edit
  def edit
  end

  # POST /attr_values
  # POST /attr_values.json
  def create
    @attr_value = AttrValue.new(attr_value_params)

    respond_to do |format|
      if @attr_value.save
        format.html { redirect_to @attr_value, notice: 'Attr value was successfully created.' }
        format.json { render :show, status: :created, location: @attr_value }
      else
        format.html { render :new }
        format.json { render json: @attr_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attr_values/1
  # PATCH/PUT /attr_values/1.json
  def update
    respond_to do |format|
      if @attr_value.update(attr_value_params)
        format.html { redirect_to @attr_value, notice: 'Attr value was successfully updated.' }
        #format.json { render :show, status: :ok, location: @attr_value }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @attr_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attr_values/1
  # DELETE /attr_values/1.json
  def destroy
    @attr_value.destroy
    respond_to do |format|
      format.html { redirect_to attr_values_url, notice: 'Attr value was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attr_value
      @attr_value = AttrValue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attr_value_params
      params[:attr_value]
    end
end
