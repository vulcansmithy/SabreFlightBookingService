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
  
  def exp1
    new_session = Session.establish
  end 
  
  def exp2
    message_header = {
  
      "mes:From" => {
        "mes:PartyId" => "",
        :attributes! => { 
          "type" => "urn:x12.org:IO5:01"
        }  
      }
  
      "mes:To"   => {
        "mes:PartyId" => "",
        :attributes! => { 
          "type" => "urn:x12.org:IO5:01"
        }
      }

    }
  end   
  
end