Rails.application.routes.draw do

  resources :downloads
  resources :exp_types
  resources :exps do
    collection do
      get :batch_upload_form
      post :batch_upload
    end
  end
  resources :attr_values

  resources :attrs

  resources :pages do
    collection do 
      post :choose_lab
      get :trackhubs
      get :logout
      get :welcome
      get :search
    end
  end

#  resources :welcome
  resources :login do
    collection do 
      get :auth
      get :form_choose_lab
      end
  end

  resources :measurement_rels

  resources :projects, param: :key do 
    member do
      post :save_samples
      post :save_measurements
    end
  end

  resources :fus

  resources :measurements do
    member do
      get :download
    end
    collection do
      get :index_slickgrid_m
      post :delete_batch
      post :download_batch
      post :save_batch
    end
  end

  resources :permissions

  resources :group_permissions

  resources :groups

  resources :users

  resources :labs

  resources :samples do
    collection do
      get :index_slickgrid
      get :test
      post :delete_batch
      post :save_batch
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  root :to => 'pages#welcome'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

   match '/treeview', to: 'pages#treeview', via: [:get]
   match '/trackhubs', to: 'pages#trackhubs', via: [:get]
   match '/logout', to: 'pages#logout', via: [:get]
  match '/search', to: 'pages#search', via: [:get]


end
