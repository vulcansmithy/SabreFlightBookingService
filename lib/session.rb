class Session
  
  SESSION_CREATE_RQ_WSDL = "http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl"
  
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :ref_message_id, 
                :account_email, 
                :domain
  
  def initialize
    initialize_configuration
  end              
                

  def initialize_configuration
    
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
      @account_email = ENV["account_email"]
    end
    
    # TODO is 'domain' a required field
    # retrieve setting for 'domain'  
    if ENV["domain"].nil?
      raise "Missing 'account_email' configuration setting." 
    else
      @domain = ENV["domain"]
    end
    
  end

  def establish
    savon_client = Savon.client(wsdl: SESSION_CREATE_RQ_WSDL, log: true, log_level: :debug, pretty_print_xml: true)
  end
  
  def build_header
    timestamp = Time.now
    
    message_header = {

      "mes:MessageHeader" => {
        "mes:From" => {
          "mes:PartyId" => "",
          :attributes! => { 
            "mes:PartyId" => {
              "type" => "urn:x12.org:IO5:01"
            } 
          }  
        },

        "mes:To"   => {
          "mes:PartyId" => "",
          :attributes! => { 
            "mes:PartyId" => {
              "type" => "urn:x12.org:IO5:01"
            }
          }
        },

        "eb:CPAId" => @ipcc,

        "mes:ConversationId" => @account_email,
      
        "mes:Service" => "",
        :attributes! => { 
          "mes:Service" => {
            "type" => "sabreXML"
          }
        },   

        "mes:Action" => "SessionCreateRQ",

        "mes:MessageData" => {
          "mes:MessageId"  => "mid:#{timestamp.strftime("%Y%m%d-%H%M%S")}@#{@domain}",
          "mes:Timestamp"  => timestamp.strftime("%Y-%m-%dT%H:%M:%SZ"),
          "mes:TimeToLive" => (timestamp + 20.minutes).strftime("%Y-%m-%dT%H:%M:%SZ"),
        },
      
        "mes:DuplicateElimination" => "",
        "mes:Description" => "",
      },
      :attributes! => { 
        "mes:MessageHeader" => {
          "id"      => "1",
          "version" => "1.0",
        }
      },
      
      "sec:Security" => {
        "sec:UsernameToken"  => {
          "sec:Username"     => @username,
          "sec:Password"     => @password,
          "sec:Organization" => @ipcc,
          "sec:Domain"       => "DEFAULT"
        }
      }
    }
    
    puts "@DEBUG #{__LINE__}    #{Gyoku.xml(message_header)}"
    
    return message_header
  end  
                      
end