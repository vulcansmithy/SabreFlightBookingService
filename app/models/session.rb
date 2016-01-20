class Session

  include ActiveModel::Model
  
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :ref_message_id, 
                :account_email, 
                :domain,
                :ref_message_id
                
  def initialize(attributes={})
    super
    
    # retrieve required setting for 'username'
    raise "Missing required 'username' configuration setting." if ENV["username"].nil?
    @username = ENV["username"]

    # retrieve required setting for 'password'  
    raise "Missing required 'password' configuration setting." if ENV["password"].nil?
    @password = ENV["password"]
    
    # retrieve required setting for 'ipcc'  
    raise "Missing required 'ipcc' configuration setting." if ENV["ipcc"].nil?
    @ipcc = ENV["ipcc"]
  
    # retrieve setting for 'account_email'        
    raise "Missing 'account_email' configuration setting." if ENV["account_email"].nil?
    @account_email = ENV["account_email"]
    
    # retrieve setting for 'domain'  
    raise "Missing 'domain' configuration setting." if ENV["domain"].nil?
    @domain = ENV["domain"]

  end              

end
