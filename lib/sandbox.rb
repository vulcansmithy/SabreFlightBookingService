class Sandbox
  
  def archived_exp1
    wsdl   = "http://www.webservicex.net/uszip.asmx?WSDL"
    client = Savon.client(wsdl: wsdl, log: true, log_level: :debug, pretty_print_xml: true)
    
    operations = client.operations
    puts "@DEBUG #{__LINE__}    operations=#{ap operations}"
    
    response = client.call(:get_info_by_zip, message: { "USZip" => "10026" } )
    puts "@DEBUG #{__LINE__}    #{ap response.to_hash}"
  end
  
  def archived_exp2
    cert_wsdl_url = "http://wsdl-crt.cert.sabre.com/sabreXML1.0.00/usg/SessionCreateRQ.wsdl"
    client        = Savon.client(wsdl: cert_wsdl_url, log: true, log_level: :debug, pretty_print_xml: true)
    
    operations = client.operations
    puts "@DEBUG #{__LINE__}    operations=#{ap operations}"
  end
  
  def util1
    time_now = Time.now
    
    message_id   = "mid:#{time_now.strftime("%Y%m%d-%H%M%S")}@deferointernational.com"
    timestamp    =  time_now.strftime("%Y-%m-%dT%H:%M:%SZ")
    
    puts "@DEBUG #{__LINE__}    message_id...   #{message_id}"
    puts "@DEBUG #{__LINE__}    timestamp....   #{timestamp}"
  end  
  
  def exp1
    new_session = Session.new
    new_session.establish
  end 
  
  def exp2
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

        "eb:CPAId" => "6A3H",

        "mes:ConversationId" => "ulysses.legaspi@deferointernational.com",
      
        "mes:Service" => "",
        :attributes! => { 
          "mes:Service" => {
            "type" => "sabreXML"
          }
        },   

        "mes:Action" => "SessionCreateRQ",

        "mes:MessageData" => {
          "mes:MessageId"  => "mid:20151222-020311@deferointernational.com",
          "mes:Timestamp"  => "2015-12-22T02:25:33Z",
          "mes:TimeToLive" => "2016-12-22T02:25:33Z",
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
          "sec:Username"     => "7971",
          "sec:Password"     => "WS288071",
          "sec:Organization" => "6A3H",
          "sec:Domain"       => "DEFAULT"
        }
      }
    }
    
    
    
    puts Gyoku.xml(message_header)
  end   
  
  def exp3
    message_body = {
      "ns:SessionCreateRQ" => {
        "ns:POS" => {
          "ns:Source" => "",
          :attributes! => { 
            "ns:Source" => {
              "PseudoCityCode" => "6A3H"
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
  end  

end