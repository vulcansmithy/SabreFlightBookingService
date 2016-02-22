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
  
  def archived_exp3
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
  
  def archived_exp4
    new_session = Sessionn.new
    new_session.establish
  end 
  
  def archived_exp5
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
  
  def archived_exp6
    message_body = {
      "xsd1:POS" => build_pos_section,
      "xsd1:OriginDestinationInformation" => {
        
        :@RPH => "1",
        
        # DepartureDateTime
        "xsd1:DepartureDateTime" => "2016-02-14T00:00:00",
        
        # OriginLocation
        "xsd1:OriginLocation" => {
          :@LocationCode => "MNL",
        },

        # DestinationLocation
        "xsd1:DestinationLocation" => {
          :@LocationCode => "SIN",     
        },

      },
    }
    
    puts "@DEBUG #{__LINE__}    #{Gyoku.xml(message_body)}"
  end
  
  def archived_exp7
    data = [
      {
        :departure_date_time  => "2016-02-14T00:00:00",
        :origin_location      => "MNL",
        :destination_location => "SIN",
      },
=begin  
      {
        :departure_date_time  => "2016-02-22T00:00:00",
        :origin_location      => "SIN",
        :destination_location => "CGK",
      },
      {
        :departure_date_time  => "2016-02-24T00:00:00",
        :origin_location      => "CGK",
        :destination_location => "BKK",
      },
      {
        :departure_date_time  => "2016-02-28T00:00:00",
        :origin_location      => "BKK",
        :destination_location => "MNL",
      },
=end      
    ]


    array_of_origins_and_destinations = []
    
    count = 0
    data.each do |entry|
      count += 1
      array_of_origins_and_destinations << {
        :@RPH => count,
        "ns:DepartureDateTime"   => entry[:departure_date_time ],
        "ns:OriginLocation"      => entry[:origin_location     ],
        "ns:DestinationLocation" => entry[:destination_location],
      }
    end
    
    origin_destination_information_collection = {
      "ns:OriginDestinationInformation" => array_of_origins_and_destinations
    }

    puts "@DEBUG #{__LINE__}    #{ap origin_destination_information_collection}"
    puts "@DEBUG #{__LINE__}    #{Gyoku.xml(origin_destination_information_collection)}"
  end
  
  def archived_exp8
    
    passenger_types_and_quantities = [
      {
        :passenger_type => "ADT",
        :quantity       => 1,
      },
      {
        :passenger_type => "CNN",
        :quantity       => 1, 
      },
      {
        :passenger_type => "INF",
        :quantity       => 1,
      },
    ]
    
    passenger_type_quantity_list = []
    
    seats_requested = 0
    passenger_types_and_quantities.each do |entry|
      passenger_type_quantity_list << {
        :@Code     => entry[:passenger_type],
        :@Quantity => entry[:quantity      ],
      }
      seats_requested += entry[:quantity]
    end
    
    return seats_requested, passenger_type_quantity_list
  end
  
  def util1
    time_now = Time.now
    
    message_id   = "mid:#{time_now.strftime("%Y%m%d-%H%M%S")}@deferointernational.com"
    timestamp    =  time_now.strftime("%Y-%m-%dT%H:%M:%SZ")
    
    puts "@DEBUG #{__LINE__}    message_id...   #{message_id}"
    puts "@DEBUG #{__LINE__}    timestamp....   #{timestamp}"
  end  
  
  def build_pos_section
    section = {
      "xsd1:Source" => {
        
        :@PseudoCityCode => "6A3H",
        
        "xsd1:RequestorID" => {
          
          :@Type => "1",
          :@ID   => "1",

          "xsd1:CompanyName" => {
            :@Code => "TN",  
          },
          
        },

      },
    }
    
    return section
  end

end