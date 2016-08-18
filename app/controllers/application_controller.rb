class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :get_user, :get_lab
  helper_method :admin?

  def get_user
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  def get_lab
    @lab = Lab.find(session[:lab_id]) if session[:lab_id]
  end

  def admin?
    @user and @user.groups.select{|g| g.name == 'Admins'}.size > 0
  end

   def create_key(model, num)
     # create unique key for request                                                                                                                 
     rnd = Array.new(num){[*'0'..'9', *'a'..'z'].sample}.join
     while(model.find_by_key(rnd)) do
       rnd = Array.new(num){[*'0'..'9', *'a'..'z'].sample}.join
     end
     return rnd
   end
   

end
