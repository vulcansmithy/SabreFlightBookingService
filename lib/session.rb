class Session
  
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :ref_message_id, 
                :account_email, 
                :domain

  def initialize
    puts "@DEBUG #{__LINE__}    Running inside initialize..."  
    puts "@DEBUG #{__LINE__}    ENV['foo']=#{ENV["foo"]}"
  end
                
end