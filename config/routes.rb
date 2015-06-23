Rails.application.routes.draw do

	namespace :api, defaults: {format: :json} do
		namespace :v1 do
			match 'tags/search/:keyword' => 'tags#search', :via => :get, as: :tags_search 
			match 'users/check' => 'users#check', :via => :post, as: :check_user
			match 'users/login' => 'users#login', :via => :post, as: :login_user
			match 'users/:id/recipes' => 'users#recipes', :via => :get, as: :users_recipe
			#match 'recipes/users/:id' => 'recipes#users', :via => :get, as: :users_recipe
			#match 'recipes/user/:id' => 'recipes#user', :via => :get, as: :user_recipe
			match 'recipes/:id/image' => 'recipes#image', :via => :post, as: :users_image
			match 'recipes/test' => 'recipes#test', :via => :get, as: :recipes_test
			match 'recipes/search/:keyword' => 'recipes#search', :via => :get, as: :recipes_search
			resources :users
			resources :tags
			resources :recipes
		end
	end
	
	get 'welcome/index'
	root 'welcome#index'
	
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
