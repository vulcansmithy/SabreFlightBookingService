class Sandbox
  
  def exp1
    wsdl   = "http://www.webservicex.net/uszip.asmx?WSDL"
    client = Savon.client(wsdl: wsdl, log: true, log_level: :debug, pretty_print_xml: true)
    
    operations = client.operations
    puts "@DEBUG #{__LINE__}    operations=#{ap operations}"
    
    response = client.call(:get_info_by_zip, message: { "USZip" => "10026" } )
    puts "@DEBUG #{__LINE__}    #{ap response.to_hash}"
  end
  
end