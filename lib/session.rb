class Session
  
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :ref_message_id, 
                :account_email, 
                :domain

  def initialize
    @username      = ENV["username"     ]
    @password      = ENV["password"     ]
    @ipcc          = ENV["ipcc"         ]
    @account_email = ENV["account_email"]
    @domain        = ENV["domain"       ]
  end

  def self.establish
    puts "@DEBUG #{__LINE__}    Running inside establish..."
  end
                      
end