class Session
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  SESSION_CREATE_RQ_WSDL          = "http://webservices.sabre.com/wsdl/sabreXML1.0.00/usg/SessionCreateRQ.wsdl"
  HEADER_ACTION_SESSION_CREATE_RQ = "SessionCreateRQ"
  HEADER_ACTION_SESSION_CLOSE_RQ  = "SessionCloseRQ"

  # == Attributes =============================================================
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :account_email, 
                :domain,
                :ref_message_id
                
  # == Initalizer ============================================================              
  def initialize(attributes={})
    super
    
    # retrieve required setting for 'username'
    raise "Missing required 'username' configuration setting." if ENV["username"].nil?
    @username = attributes[:username].nil? ? ENV["username"] : attributes[:username] 

    # retrieve required setting for 'password'  
    raise "Missing required 'password' configuration setting." if ENV["password"].nil?
    @password = attributes[:password].nil? ? ENV["password"] : attributes[:password] 
    
    # retrieve required setting for 'ipcc'  
    raise "Missing required 'ipcc' configuration setting." if ENV["ipcc"].nil?
    @ipcc = attributes[:ipcc].nil? ? ENV["ipcc"] : attributes[:ipcc] 
  
    # retrieve setting for 'account_email'        
    raise "Missing 'account_email' configuration setting." if ENV["account_email"].nil?
    @account_email = attributes[:account_email].nil? ? ENV["account_email"] : attributes[:account_email] 
    
    # retrieve setting for 'domain'  
    raise "Missing 'domain' configuration setting." if ENV["domain"].nil?
    @domain = attributes[:domain].nil? ? ENV["domain"] : attributes[:domain] 

  end              

  # == Instance methods =======================================================
  def build_header(header_action, binary_security_token=nil)
    raise "Missing 'header_action' parameter." if header_action.nil?
    
    time_now = Time.now
    
    message_id   = "mid:#{time_now.strftime("%Y%m%d-%H%M%S")}@#{@domain}"
    timestamp    =  time_now.strftime("%Y-%m-%dT%H:%M:%SZ")
    puts "@DEBUG #{__LINE__}    message_id..... #{message_id  }"
    puts "@DEBUG #{__LINE__}    timestamp...... #{timestamp   }"
    
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

        "mes:CPAId" => @ipcc,

        "mes:ConversationId" => @account_email,
      
        "mes:Service" => "",
        :attributes! => { 
          "mes:Service" => {
            "type" => "sabreXML"
          }
        },   

        "mes:Action" => header_action,

        "mes:MessageData" => {
          "mes:MessageId" => message_id,
          "mes:Timestamp" => timestamp,
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
        },
        "sec:BinarySecurityToken" => binary_security_token.nil? ? "" : binary_security_token,
      },
      
      
      
    }
    
    puts "@DEBUG #{__LINE__}    #{Gyoku.xml(message_header)}"

    
    return message_header
  end  
  
  def create_session_token
    begin
      namespaces = {
        "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
        "xmlns:ns"  => "http://www.opentravel.org/OTA/2002/11",
        "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
        "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
      }
    
      message_body = {
        "ns:SessionCreateRQ" => {
          "ns:POS" => {
            "ns:Source" => "",
            :attributes! => { 
              "ns:Source" => {
                "PseudoCityCode" => @ipcc
              }
            }
          }
        },
        :attributes! => { 
          "ns:SessionCreateRQ" => {
            "returnContextID" => "1"
          }
        }
      }

      savon_client = Savon.client(
        wsdl:                    SESSION_CREATE_RQ_WSDL, 
        namespaces:              namespaces,
        soap_header:             build_header(HEADER_ACTION_SESSION_CREATE_RQ),
        log:                     true, 
        log_level:               :debug, 
        pretty_print_xml:        true,
        convert_request_keys_to: :none
      )
    
      response = savon_client.call(:session_create_rq, message: message_body)
      
    rescue Savon::SOAPFault => error
      
      if error.to_hash[:fault][:faultcode] == "soap-env:Client.AuthenticationFailed"
        raise "Authentication failed." 
      else
        raise "Exception encountered."
      end    

    else
      @binary_security_token = response.xpath("//wsse:BinarySecurityToken")[0].content 

      return @binary_security_token     
    end
  end
  
  def establish_session
    self.create_session_token
  end  
  
  def re_establish_session
    self.create_session_token
  end
end
