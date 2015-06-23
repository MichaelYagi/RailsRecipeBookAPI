class User < ActiveRecord::Base

	validates_presence_of :hash
	validates_presence_of :username

	validates_uniqueness_of :username

	has_one :user_email
	has_many :recipes
	
	before_create do |doc|
		doc.api_key = doc.generate_api_key
	end

	def generate_api_key
		loop do
			token = SecureRandom.base64.tr('+/=', 'Qrt')
			break token unless User.exists?(api_key: token)
		end
	end
	
end