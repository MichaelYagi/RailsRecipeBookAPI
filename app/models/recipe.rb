class Recipe < ActiveRecord::Base
	has_one :user
	has_many :ingredients
	has_many :steps
	has_many :recipe_images
	has_many :recipe_x_tags
	has_many :tags, :through => :recipe_x_tags
	
	belongs_to :user
end