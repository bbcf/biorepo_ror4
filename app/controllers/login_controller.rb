class LoginController < ApplicationController
include Tequila

  # GET /samples
  # GET /samples.json
  def index
    res = create_request2(root_url + '/login/auth', 'tequila.epfl.ch')
    redirect_to ('https://tequila.epfl.ch/cgi-bin/tequila/requestauth?request' + res)
  end

  def auth
    
    @h_labs = {}
    Lab.all.map{|g| @h_labs[g.id]=g}

    if !params[:key] #not kw.has_key('key'):
      raise redirect(root_path)
    end
    # take parameters                                                                                                                                                                              
    key = params[:key]
    environ = request.env
    authentication_plugins = environ['repoze.who.plugins']
    identifier = authentication_plugins['ticket'] if authentication_plugins
    if identifier
      secret = identifier.secret
      cookiename = identifier.cookie_name
    end
    remote_addr = request.remote_addr 
    # get user                                                                                                                                                                                     
    principal = validate_key(key, 'tequila.epfl.ch')
    if !principal
      redirect_to :action => :index
    else
      #    #in case of user gets several labs                                                                                                                                                           
      #    if session[:first_passage] == false
      #      #second passage                                                                                                                        
      #      tmp_user = session[:tmp_user]
      #      tmp_lab = session[:tmp_lab]
      #    end
      
      #first passage      
      session[:first_passage] == true
      session[:principal_tequila] = principal
      #session.save()
      
      @h = {}
      principal.split("\n").map{|l| t=l.split('='); @h[t[0]]=t[1]}
      
logger.debug('PRINCIPAL=' + @h.to_s)
      @user = User.find_by_email(@h['email'])
# effort to create new user
      if !@user
        user_param = {
            :name => @h['name'],
            :firstname => @h['firstname'],
            :email =>@h['email']
        }
        @user = User.create(user_param)
        @lab = Lab.find_by_name(@h['allunits'])
        logger.debug('LAB:' + @lab.id.to_s)
        @user.labs << @lab
      end

      session[:user_id] = @user.id
      @labs = @user.labs

      respond_to do |format|
        if @labs.size > 1 and !session[:lab_id]
          format.html {render 'form_choose_lab'}
        else          
          session[:lab_id] = @labs.first.id
          @lab = @h_labs[session[:lab_id]]
#          redirect_to root_path # new.html.erb                                                              
          format.html
        end
      end
    end
  end

  
  # GET /samples/1
  # GET /samples/1.json
  def show
  
    respond_to do |format|
      format.html # show.html.erb
  #    format.json { render json: @sample }
    end
  end

  # GET /samples/new
  # GET /samples/new.json
  def new
  
    respond_to do |format|
      format.html # new.html.erb
   #   format.json { render json: @sample }
    end
  end

  # GET /samples/1/edit
  def edit
   
  end

  # POST /samples
  # POST /samples.json
  def create
   # @sample = Sample.new(params[:sample])

   # respond_to do |format|
   #   if @sample.save
   #     format.html { redirect_to @sample, notice: 'Sample was successfully created.' }
   #     format.json { render json: @sample, status: :created, location: @sample }
   #   else
   #     format.html { render action: "new" }
   #     format.json { render json: @sample.errors, status: :unprocessable_entity }
   #   end
   # end
  end

  # PUT /samples/1
  # PUT /samples/1.json
  def update
   # @sample = Sample.find(params[:id])

 #   respond_to do |format|
 #     if @sample.update_attributes(params[:sample])
 #       format.html { redirect_to @sample, notice: 'Sample was successfully updated.' }
 #       format.json { head :no_content }
 #     else
 #       format.html { render action: "edit" }
 #       format.json { render json: @sample.errors, status: :unprocessable_entity }
 #     end
 #   end
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy
 #   @sample = Sample.find(params[:id])
 #   @sample.destroy

#    respond_to do |format|
#      format.html { redirect_to samples_url }
#      format.json { head :no_content }
#    end
  end
end
