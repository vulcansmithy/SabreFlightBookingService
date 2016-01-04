class Session
  
  SESSION_CREATE_RQ_WSDL = "http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl"
  
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :ref_message_id, 
                :account_email, 
                :domain

  def self.initialize_configuration
    
    # retrieve required setting for 'username'
    if ENV["username"].nil?
      raise "Missing required 'username' configuration setting." 
    else  
      @username = ENV["username"]
    end
    
    # retrieve required setting for 'password'  
    if ENV["password"].nil?
      raise "Missing required 'password' configuration setting." 
    else  
      @password = ENV["password"]
    end
    
    # retrieve required setting for 'ipcc'  
    if ENV["ipcc"].nil?
      raise "Missing required 'ipcc' configuration setting." 
    else
      @ipcc = ENV["ipcc"]
    end
  
     # TODO is 'domain' a required field
    # retrieve setting for 'account_email'        
    if ENV["account_email"].nil?
      raise "Missing 'account_email' configuration setting." 
    else
      @ipcc = ENV["account_email"]
    end
    
    # TODO is 'domain' a required field
    # retrieve setting for 'domain'  
    if ENV["domain"].nil?
      raise "Missing 'account_email' configuration setting." 
    else
      @domain = ENV["domain"]
    end
    
  end

  def self.establish
    initialize_configuration
    
    savon_client = Savon.client(wsdl: SESSION_CREATE_RQ_WSDL, log: true, log_level: :debug, pretty_print_xml: true)
  end
                      
end