class Api::V1::UsersController < Api::ApiController
	respond_to :html, :xml, :json
	
	before_action :authenticate, :except => [:login, :check, :create, :recipes]

	def create
		
		username = params[:username]
		email = params[:email]
		hash = generateHash(params[:password])
		
		# Save user and email
		@user = User.new
		@user.username = username
		@user.hash = hash
		@user.suspended = 0
		@user.added = Time.now
		@user.modified = Time.now
		@user.save!
					
		@user_email = UserEmail.new
		@user_email.user_id = @user.id
		@user_email.email = email
		@user_email.save!
		
		@user = User.select('*').joins(:user_email).find(@user.id)
				
		render :json => @user
	end
	
	def login
		username = params[:username]
		password = params[:password]
		@user = nil
		
		@user_username = User.select('*').joins(:user_email).find_by_username(username)
		
		if !@user_username
			@user_email = UserEmail.find_by_email(username)
			puts @user_email.inspect
			if  @user_email
				@user = User.select('*').joins(:user_email).find(@user_email.user_id)
			end
		else
			@user = @user_username
		end
		
		if @user && @user[:hash] = password.crypt(@user[:hash])
			json_data = JSON.parse(@user.to_json)
			json_data.delete("hash")
			render :json => json_data
		else
			@user = {:id => 0}
			render :json => @user
		end
	end
	
	def recipes
		api_key = request.headers['X-Api-Key']
		
		@user = User.where(api_key: api_key).first if api_key
		
		ret_recipe = {:id => 0}	
				
		ret_recipe = JSON.parse(User.where(["id = ?", params[:id]]).select("id, username").first.to_json)
				
		# View my own recipes. If logged in, and param id passed is same user
		if (!@user.nil? && @user.id.to_i == params[:id].to_i)
			ret_recipe['recipes'] = JSON.parse(Recipe.where(user_id: params[:id]).all.to_json)
		elsif
			# Else view only published
			ret_recipe['recipes'] = JSON.parse(Recipe.where(user_id: params[:id], published: 1).all.to_json)
		end
								
		respond_with ret_recipe
	end

	def show
	end
	
	def check
		# Check if duplicate on username or email			
		@exists = false
		@ret = 1
		
		if params[:username]
			@exists = User.exists?(:username => params[:username])
		elsif params[:email]	
			@exists = UserEmail.exists?(:email => params[:email])
		end
		
		if @exists
			@ret = 0
		end
		
		@ret = {:response => @ret}
		
		render :json => @ret
	end
	
	private
	def generatePassword(length = 5)
		characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
		charactersLength = characters.length;
		randomString = '';
		
		0.upto(length-1) do |i|
			randomString += characters[rand(0, charactersLength-1)];
		end
		
		return randomString;
	end
	
	def generateHash(password)
		# A higher "cost" is more secure but consumes more processing power
		cost = 10;
		
		# Create a random salt
		o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
		salt = (0...50).map { o[rand(o.length)] }.join
								
		# Hash the password with the salt
		hash = password.crypt(salt);
		
		return hash;
	end
	
	def strtr(replace_pairs)
		keys = replace_pairs.map {|a, b| a }
		values = replace_pairs.map {|a, b| b }
		self.gsub(
		  /(#{keys.map{|a| Regexp.quote(a) }.join( ')|(' )})/
		  ) { |match| values[keys.index(match)] }
  	end
	
end