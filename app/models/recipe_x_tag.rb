class RecipeXTag < ActiveRecord::Base
	belongs_to :recipe
	belongs_to :tag
	
	has_many :recipes
	has_many :tags
end