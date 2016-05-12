class SabreSession
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  SESSION_CREATE_RQ_WSDL          = "http://webservices.sabre.com/wsdl/sabreXML1.0.00/usg/SessionCreateRQ.wsdl"
  NON_PRODUCTION_ENDPOINT         = "https://sws3-crt.cert.sabre.com"
  PRODUCTION_ENDPOINT             = "https://webservices3.sabre.com"
  
  HEADER_ACTION_SESSION_CREATE_RQ = "SessionCreateRQ"
  HEADER_ACTION_SESSION_CLOSE_RQ  = "SessionCloseRQ"

  # == Attributes =============================================================
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :account_email, 
                :domain,
                :ref_message_id,
                :non_production_environment
                
                
  # == Initalizer ============================================================              
  def initialize(attributes={})
    super

    # retrieve required setting for 'USERNAME'
    raise "Missing required 'SABRE_ACCOUNT_USERNAME' configuration setting." if ENV["USERNAME"].nil?
    @username = attributes[:username].nil? ? ENV["USERNAME"] : attributes[:username] 

    # retrieve required setting for 'PASSWORD'  
    raise "Missing required 'PASSWORD' configuration setting." if ENV["PASSWORD"].nil?
    @password = attributes[:password].nil? ? ENV["PASSWORD"] : attributes[:password] 
    
    # retrieve required setting for 'IPCC'  
    raise "Missing required 'IPCC' configuration setting." if ENV["IPCC"].nil?
    @ipcc = attributes[:ipcc].nil? ? ENV["IPCC"] : attributes[:ipcc] 
  
    # retrieve setting for 'ACCOUNT_EMAIL'        
    raise "Missing 'ACCOUNT_EMAIL' configuration setting." if ENV["ACCOUNT_EMAIL"].nil?
    @account_email = attributes[:account_email].nil? ? ENV["ACCOUNT_EMAIL"] : attributes[:account_email] 
    
    # retrieve setting for 'DOMAIN'  
    raise "Missing 'DOMAIN' configuration setting." if ENV["DOMAIN"].nil?
    @domain = attributes[:domain].nil? ? ENV["DOMAIN"] : attributes[:domain] 

    @non_production_environment = false
    
    @message_body   = {}
    @message_header = {}
  end              

  # == Instance methods =======================================================
  def build_header(header_action, binary_security_token=nil)
    raise "Missing 'header_action' parameter." if header_action.nil?
    
    time_now = Time.now
    
    message_id   = "mid:#{time_now.strftime("%Y%m%d-%H%M%S")}@#{@domain}"
    timestamp    =  time_now.strftime("%Y-%m-%dT%H:%M:%SZ")
    puts "@DEBUG #{__LINE__}    message_id..... #{message_id  }"
    puts "@DEBUG #{__LINE__}    timestamp...... #{timestamp   }"
    
    @message_header = {
  
      "mes:MessageHeader" => {
        :@id      => "1",
        :@version => "1.0",

        "mes:From" => {
          "mes:PartyId" => { :@type => "urn:x12.org:IO5:01" },
        },

        "mes:To" => {
          "mes:PartyId" => { :@type => "urn:x12.org:IO5:01" },   
        },

        "mes:CPAId" => @ipcc,

        "mes:ConversationId" => @account_email,
      
        "mes:Service" => { :@type => "sabreXML" },

        "mes:Action" => header_action,

        "mes:MessageData" => {
          "mes:MessageId" => message_id,
          "mes:Timestamp" => timestamp,
        },
      
        "mes:DuplicateElimination" => "",
        "mes:Description" => "",
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
    
    puts "@DEBUG #{__LINE__}    #{Gyoku.xml(@message_header)}"

    return @message_header
  end  
  
  def establish_session(existing_binary_security_token=nil)
    create_session_token(existing_binary_security_token)
  end  
  
  def re_establish_session
    create_session_token
  end
  
  def set_to_non_production
    @non_production_environment = true
  end
  
  def set_to_production
    @non_production_environment = false
  end    

  def non_production_environment?
    return @non_production_environment
  end
  
  def set_endpoint_environment(savon_client)
    target_end_point = nil
    if non_production_environment?
      target_end_point = SabreSession::NON_PRODUCTION_ENDPOINT 
    else
      target_end_point = SabreSession::PRODUCTION_ENDPOINT 
    end  
    
    savon_client.globals.endpoint(target_end_point)
    
    return savon_client
  end  
  
  def operation_attributes
    attributes = {
      "returnContextID" => "1",
    }
    
    return attributes
  end

  # == Private methods ========================================================
  private
    def create_session_token(existing_binary_security_token=nil)
      begin
        namespaces = {
          "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
          "xmlns:ns"  => "http://www.opentravel.org/OTA/2002/11",
          "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
          "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
        }
    
        @message_body = {
          "ns:POS" => {
            "ns:Source" => { :@PseudoCityCode => @ipcc, },
          },          
        } 

        @message_header = build_header(HEADER_ACTION_SESSION_CREATE_RQ, existing_binary_security_token)

        savon_client = Savon.client(
          wsdl:                    SESSION_CREATE_RQ_WSDL, 
          namespaces:              namespaces,
          soap_header:             @message_header,
          log:                     true, 
          log_level:               :debug, 
          pretty_print_xml:        true,
          convert_request_keys_to: :none,
          namespace_identifier:    :ns,
        )
      
        savon_client  = self.set_endpoint_environment(savon_client)
        call_response = savon_client.call(
          :session_create_rq, 
          soap_action: "ns:SessionCreateRQ", 
          attributes:   operation_attributes, 
          message:      @message_body
        )
      
      rescue Savon::SOAPFault => error
        puts "@DEBUG #{__LINE__}    #{ap error.to_hash[:fault]}"
      
        return { status: :failed, error: error.to_hash[:fault] }
      else
        retrieved_token = (call_response.header[:security])[:binary_security_token]
        unless retrieved_token.nil?
          @binary_security_token = retrieved_token
          return { status: :success, data: { binary_security_token: @binary_security_token } }  
        else  
          return { status: :failed,  error: "Was not able to find the BinarySecurityToken."  }
        end
      end
    end
    
end
