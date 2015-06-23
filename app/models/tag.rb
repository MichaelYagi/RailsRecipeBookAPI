class Tag < ActiveRecord::Base
	belongs_to :recipe
	
	validates_uniqueness_of :keyword
end