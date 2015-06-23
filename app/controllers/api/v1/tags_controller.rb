class Api::V1::TagsController < Api::ApiController
	respond_to :html, :xml, :json
	
	before_action :authenticate, :except => [:index, :search, :show]
	
	def index
		@tags = Tag.all
		
		respond_with @tags	
	end
	
	def show
		
		tag = Tag.find(params[:id])
		ret_val = JSON.parse(tag.to_json)
	
		recipe = Recipe.joins(:recipe_x_tags, :user).where("recipe_x_tags.tag_id" => params[:id], "recipes.published" => true).select("recipes.*, users.username, users.id AS user_id")
		ret_val['recipes'] = JSON.parse(recipe.to_json)		
		
		respond_with ret_val
	end
	
	def search
		keyword = params[:keyword]
	
		@tags = Tag.where("lower(keyword) LIKE ?","%#{keyword}%").select('keyword')
		
		@tags = @tags.map { |tag| {:keyword => tag.keyword} }
		
		puts @tags.to_json

		respond_with @tags
	end
	
	def self.pluck_to_hash(keys)
		pluck(*keys).map{|pa| Hash[*keys.zip(pa).flatten]}
	end
end
