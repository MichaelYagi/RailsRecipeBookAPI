class Api::V1::RecipesController < Api::ApiController
	respond_to :html, :xml, :json
	
	before_action :authenticate, :except => [:index, :show, :users, :search]
	
	def index
		
		@recipes = Recipe.where(:published => 1).select('recipes.*')
		
		ret_recipe = JSON.parse(@recipes.to_json)
		
		respond_with ret_recipe
	end
	
	def create
		new_recipe = JSON.parse(params[:new_recipe])
		
		# Create recipe
		@recipe = Recipe.new
		@recipe.title = new_recipe["title"]
		@recipe.prep_time = new_recipe["prep_time"]
		@recipe.cook_time = new_recipe["cook_time"]
		@recipe.serves = new_recipe["serves"]
		@recipe.user_id = @user.id
		@recipe.added = Date.today
		@recipe.modified = Date.today
		@recipe.published = new_recipe["published"]
		@recipe.save!
				
		
		if @recipe.id > 0	
			# Create tags
			tags = new_recipe["tags"].map { |tag| tag["keyword"].downcase.strip }
			
			if tags.size > 0
				existing_tags = Tag.where("lower(keyword) IN (?)", tags)
				new_tags = tags - (existing_tags.map { |existing_tag| existing_tag.keyword.downcase })
			
				if new_tags.size > 0
					new_tags = new_tags.map { |new_tag| {:keyword => new_tag} }
					Tag.create(new_tags)
					keywords = new_tags.map {|tag| tag[:keyword]}
					tags = Tag.where(keyword: keywords)
					new_recipextags = tags.select('id').map {|tag_id|{:recipe_id => @recipe.id ,:tag_id => tag_id.id}}
					RecipeXTag.create(new_recipextags)
				end
		
				if existing_tags.size > 0
					new_recipextags = existing_tags.select('id').map { |tag_id| {:recipe_id => @recipe.id ,:tag_id => tag_id.id} } 
					RecipeXTag.create(new_recipextags)
				end
			end
		
		
			# Create ingredients
			index = 1
			ingredients = []
			new_recipe["ingredients"].each do |ingredient|
		
				if [ingredient["amount"],ingredient["unit"],ingredient["ingredient"]].any? { |field| !field.blank? }
					ingredients.push({:recipe_id => @recipe.id, :sort_order => index, :amount => ingredient["amount"], :unit => ingredient["unit"],:ingredient => ingredient["ingredient"],:added => Date.today,:modified => Date.today})
					index+=1
				end
			end
			if ingredients.size > 0
				Ingredient.create(ingredients)
			end
		
			# Create steps
			index = 1
			steps = []
			new_recipe["steps"].each do |step|
				if !step["description"].blank?
					steps.push({:recipe_id => @recipe.id, :sort_order => index, :description => step["description"], :added => Date.today, :modified => Date.today})
					index+=1
				end
			end
			if steps.size > 0
				Step.create(steps)
			end
		end
		
		@recipe = Recipe.find(@recipe.id)
		
		json_data = JSON.parse(@user.to_json)
		
		render :json => JSON.parse(@recipe.to_json)
		
	end
	
	def update
		edit_recipe = JSON.parse(params[:edit_recipe])
	
		puts edit_recipe.inspect
		
		@recipe = Recipe.find(params[:id])
		
		ret_recipe = {:id => 0}.to_json		
				
		if @recipe["user_id"] == @user.id
		
			# Update recipe
			Recipe.where(:id => params[:id]).update_all(:title => edit_recipe["title"],
														:prep_time => edit_recipe["prep_time"], 
														:cook_time => edit_recipe["cook_time"], 
														:serves => edit_recipe["serves"], 
														:published => edit_recipe["published"], 
														:modified => Date.today)
	
			# Wipe, insert ingredients
			index = 1
			ingredients = []
			edit_recipe["ingredients"].each do |ingredient|
				if [ingredient["amount"],ingredient["unit"],ingredient["ingredient"]].any? { |field| !field.blank? }
					ingredients.push({:recipe_id => @recipe.id, :sort_order => index, :amount => ingredient["amount"], :unit => ingredient["unit"],:ingredient => ingredient["ingredient"],:added => Date.today,:modified => Date.today})
					index+=1
				end
			end
			if ingredients.size > 0
				Ingredient.where(:recipe_id => @recipe.id).destroy_all
				Ingredient.create(ingredients)
			end
		
			# Wipe, insert steps
			index = 1
			steps = []
			edit_recipe["steps"].each do |step|
				if !step["description"].blank?
					steps.push({:recipe_id => @recipe.id, :sort_order => index, :description => step["description"], :added => Date.today, :modified => Date.today})
					index+=1
				end
			end
			if steps.size > 0
				Step.where(:recipe_id => @recipe.id).destroy_all
				Step.create(steps)
			end
			
			# Wipe, insert tags
			tags = edit_recipe["tags"].map { |tag| tag["keyword"].downcase.strip }
			
			if tags.size > 0
			
				existing_tags = Tag.where("lower(keyword) IN (?)", tags)
				new_tags = tags - (existing_tags.map { |existing_tag| existing_tag.keyword.downcase })
				@recipe.tags.destroy_all
			
				if new_tags.size > 0
					new_tags = new_tags.map { |new_tag| {:keyword => new_tag} }
					Tag.create(new_tags)
					keywords = new_tags.map {|tag| tag[:keyword]}
					tags = Tag.where(keyword: keywords)
					new_recipextags = tags.select('id').map {|tag_id|{:recipe_id => @recipe.id ,:tag_id => tag_id.id}}
					RecipeXTag.create(new_recipextags)
				end
		
				if existing_tags.size > 0
					new_recipextags = existing_tags.select('id').map { |tag_id| {:recipe_id => @recipe.id ,:tag_id => tag_id.id} } 
					RecipeXTag.create(new_recipextags)
				end
			end
		
			# Delete images
			if edit_recipe["images"].size > 0
				delete_images = edit_recipe["images"].select {|image| image["delete"] == true }
				if delete_images.size > 0
					delete_image_ids = delete_images.map {|image| image["id"]}
					RecipeImage.where(:id => delete_image_ids).destroy_all		
					
					delete_images.each do |image|
						file_name = image["id"].to_s + '.' + image["ext"]
						directory = Rails.root.join('public','images',@recipe.id.to_s)
						full_file_path = directory + file_name
						if File.exist?(full_file_path)
							File.delete(full_file_path)
						end
					end
				end
			end
		
			ret_recipe = {:id => @recipe.id}.to_json	
		end
		
		render :json => JSON.parse(ret_recipe)
		
	end
	
	def show
		
		api_key = request.headers['X-Api-Key']
		
		@user = User.where(api_key: api_key).first if api_key
		
		@recipe = Recipe.find(params[:id])
		
		ret_recipe = {:id => 0}.to_json	
		
		if @recipe.published == 1 || @recipe.published || (!@user.nil? && @recipe.user_id == @user.id)
		
			ret_recipe = JSON.parse(@recipe.to_json)
		
			# Get ingredients
			ret_recipe["ingredients"] = JSON.parse(@recipe.ingredients.to_json)

			# Get steps
			ret_recipe["steps"] = JSON.parse(@recipe.steps.to_json)
			
			# Get tags
			ret_recipe["tags"] = JSON.parse(@recipe.tags.to_json)
			
			# Get Image ids
			ret_recipe["images"] = JSON.parse(@recipe.recipe_images.to_json)
		end
		
		respond_with ret_recipe
		
	end
	
	def image
		@recipe = Recipe.find(params[:id])
		
		#Create entry in db
		@image = RecipeImage.new
		@image.extension = File.extname(params[:file].instance_variable_get(:@original_filename)).delete('.')
		@image.recipe_id = @recipe.id
		@image.added = Date.today
		@image.save!		
		
		# Create image directory for recipe id if doesn't exist
		directory_name = Rails.root.join('public','images',@recipe.id.to_s)
		Dir.mkdir(directory_name) unless File.exists?(directory_name)
		
		require 'fileutils'
		tmp = params[:file].instance_variable_get(:@tempfile)
		filename = @image.id.to_s + "." + @image.extension
		file = File.join('public','images',@recipe.id.to_s, filename)
		FileUtils.cp tmp.path, file
		FileUtils.rm tmp.path
		
		render :json => JSON.parse(@image.to_json)
	end
	
	def search

		keyword = "%#{params[:keyword].gsub('%', '\%').gsub('_', '\_')}%"
		
		@recipes = Recipe.uniq.joins(:user).joins("LEFT JOIN recipe_x_tags ON recipe_x_tags.recipe_id = recipes.id").joins("LEFT JOIN tags ON tags.id = recipe_x_tags.tag_id").where('recipes.published = 1 AND (recipes.title LIKE ? OR tags.keyword LIKE ?)', keyword, keyword).select('recipes.*, users.username')
		
		respond_with @recipes
	end
	
	# Publicly shown recipes by user
	def users
		@recipes = Recipe.where('published = ?',1).find_by_user_id(params[:id])
		respond_with @recipes	
	end
	
	# Signed in user recipe list
	def user
		@recipes = Recipe.find_by_user_id(params[:id])
		respond_with @recipes
	end
	
	def test
		puts "hello"
	end
	
end
