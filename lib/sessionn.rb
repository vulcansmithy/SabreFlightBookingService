class Sessionn
  
  SESSION_CREATE_RQ_WSDL = "http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl"
  
  attr_accessor :username, 
                :password, 
                :ipcc, 
                :binary_security_token, 
                :ref_message_id, 
                :account_email, 
                :domain,
                :ref_message_id
  
  def initialize
    initialize_configuration
  end              
                

  def initialize_configuration
    # retrieve required setting for 'USERNAME'
    if ENV["USERNAME"].nil?
      raise "Missing required 'username' configuration setting." 
    else  
      @username = ENV["USERNAME"]
    end
    
    # retrieve required setting for 'PASSWORD'  
    if ENV["PASSWORD"].nil?
      raise "Missing required 'PASSWORD' configuration setting." 
    else  
      @password = ENV["PASSWORD"]
    end
    
    # retrieve required setting for 'IPCC'  
    if ENV["IPCC"].nil?
      raise "Missing required 'IPCC' configuration setting." 
    else
      @ipcc = ENV["IPCC"]
    end
  
    # retrieve setting for 'ACCOUNT_EMAIL'        
    if ENV["ACCOUNT_EMAIL"].nil?
      raise "Missing 'ACCOUNT_EMAIL' configuration setting." 
    else
      @account_email = ENV["ACCOUNT_EMAIL"]
    end
    
    # retrieve setting for 'DOMAIN'  
    if ENV["DOMAIN"].nil?
      raise "Missing 'DOMAIN' configuration setting." 
    else
      @domain = ENV["DOMAIN"]
    end
  end

  def establish
    
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:ns"  => "http://www.opentravel.org/OTA/2002/11",
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
    }
    
    savon_client = Savon.client(
      wsdl:                    SESSION_CREATE_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             build_header,
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none
    )
    
    response = savon_client.call(:session_create_rq, message: build_message)
    puts "@DEBUG #{__LINE__}    #{ap response.to_hash}"
    
    @binary_security_token = response.xpath("//wsse:BinarySecurityToken")[0].content
    @ref_message_id        = response.xpath("//eb:RefToMessageId"       )[0].content 
    
    puts "@DEBUG #{__LINE__}    binary_security_token='#{@binary_security_token}'"
    puts "@DEBUG #{__LINE__}    ref_message_id       ='#{@ref_message_id       }'"
  end
  
  def build_header
    time_now = Time.now
    
    message_id   = "mid:#{time_now.strftime("%Y%m%d-%H%M%S")}@#{@domain}"
    timestamp    =  time_now.strftime("%Y-%m-%dT%H:%M:%SZ"),
    time_to_live = (time_now + 20.minutes).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    puts "@DEBUG #{__LINE__}    message_id=#{message_id}"
    puts "@DEBUG #{__LINE__}    timestamp=#{timestamp}"
    puts "@DEBUG #{__LINE__}    time_to_live=#{time_to_live}"
    
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

        "mes:Action" => "SessionCreateRQ",

        "mes:MessageData" => {
          "mes:MessageId"  => message_id,
          "mes:Timestamp"  => timestamp,
          "mes:TimeToLive" => time_to_live,
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
  
  def build_message
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
    
    puts "@DEBUG #{__LINE__}    #{Gyoku.xml(message_body)}"
    
    return message_body
  end
                      
end