class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def  choose_lab

    session[:lab_id]=page_params[:lab_id]
    redirect_to :action => :welcome
    
  end

  def treeview
  end

  def trackhubs
  end

  def welcome
  end

  def search
    search = Project.search{fulltext page_params[:free_text]}
    @projects = search.results
    respond_to do |format|
      format.html {render :layout => false}# index.html.erb                                                                            
    end
  end
  
  def logout
  #  environ = request.env
  #  authentication_plugins = environ['repoze.who.plugins']
  #  identifier = authentication_plugins['ticket']
  #  cookiename = identifier.cookie_name
  #  response.delete_cookie(cookiename)
    session.delete(:user_id)
    session.delete(:lab_id)
     redirect_to root_path
    
end

  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.all
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render :new }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to @page, notice: 'Page was successfully updated.' }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render :edit }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url, notice: 'Page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params[:page]
    end
end
