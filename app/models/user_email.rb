class UserEmail < ActiveRecord::Base

	validates_presence_of :email
	validates_uniqueness_of :email

	belongs_to :user
end