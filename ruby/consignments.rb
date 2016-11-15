require_relative 'utils'


if true #Create consignment



  # Build an XML document using Nokogiri. Encoding must be UTF-8.
  document = Nokogiri::XML::Builder.new encoding: 'UTF-8' do |xml|

    # The consignment must be wrapped in a <consignments> container. There is currently no support for multiple
    # consignments per request, but it may be implemented in the future.
    xml.consignments do
      xml.consignment transport_agreement: 1, product: 'mypack' do


        # The <values> element contains name/value pairs that will be returned as-is in the response.
        # They do not serve any other purpose than to act as reference values for the requester.
        xml.values do
          xml.value name: 'order-id', value: '12345'
          xml.value name: 'customer-id', value: 'goldengod2@playfullexpressions.com'
        end

        xml.references do
          xml.consignor 'Order ID: 12345'
          xml.consignee 'Play time tools'
        end

        xml.messages do
          xml.carrier 'Handle with care'
          xml.consignee 'Private and personal. Do not give to Mac.'
        end


        xml.parts do

          xml.consignee do
            xml.name 'Dennis Reynolds'
            xml.address1 '123 Sensual St'
            xml.country 'US'
            xml.postcode '12345'
            xml.city 'Philadelphia'
          end

          xml.service_partner do
            xml.number '12345'
            xml.name 'McPoyle Video Rentals'
            xml.address1 '34 Warm Milk Ave'
            xml.country 'US'
            xml.postcode '12345'
            xml.city 'Philadelphia'
          end

          xml.return_address do
            xml.name 'Implication Tools Inc'
            xml.address1 '45 Rover St'
            xml.country 'US'
            xml.postcode '54321'
            xml.city 'Atlantic City'
          end

        end


        # Items for a consignment can be given in one of two ways:

        # The standard way is to use an <items> element, where each <item> represents a "bundle". This bundle
        # is given an "amount" of actual items in the bundle, that will be created automatically.
        xml.items do
          xml.item type: 'PK', amount: '1', weight: '0.1', width: '20', height: '30', length: '40', description: '10x latex glove w/ SensuaFeel technology'
          xml.item type: 'PK', amount: '1', weight: '0.3', description: '100x zip ties, extra strength, black'
        end


        # The second format is used when more control is desired. This format allows consignment and item numbers to be
        # given explicitly instead of being automatically generated.

        xml.number '0987654321' #The number of the consignment. It's not strictly necessary to use the second format to specify this, but it's most common

        # Each <bundle> is described explicitly
        xml.bundles do
          # The <bundle> takes the same attributes as the <item> from above, except "amount"
          xml.bundle description: 'For "the list"', weight: '1.0' do
            # Each <item> in the bundle is described explicitly, allowing a "number" attribute to be given
            xml.item type: 'PK', number: '1234567890'
            # Dangerous goods properties are given for an entire <bundle>. These can also be given for an <item> using the first format
            xml.dangerous_goods un_number: "1680", gross_weight: "1000", net_weight: "960", labels: "6.1", packing_group: "1", name: "Potassium Cyanide"
          end
          xml.bundle description: 'Denim for Frank & Charlie', weight: '20.0' do
            xml.item #An explicit number is not required for this format
          end
        end


        xml.services do
          xml.service id: 'express_delivery'
          xml.service id: 'insurance' do
            xml.currency 'USD'
            xml.amount '100'
          end
        end#services


      end#consignment
    end#consignments
  end#Builder


  #To see the generated XML
  #puts document.to_xml


  response = post '/consignments.xml', body: document.to_xml
  maybe_document = maybe_parse_xml response

  if response.code =~ /^2/
    if maybe_document
      puts "Consignment created:"
      puts
      puts maybe_document.to_xml
    else
      inspect_response response
    end
  elsif response.code == '400' && maybe_document
    puts "Errors creating consignment:"
    puts
    nodes(maybe_document, '//consignments/consignment/errors/error').each do |error|
      puts error.content
    end
  else
    inspect_response response
  end





else #Get consignments


  response = get '/consignments.xml'
  maybe_document = maybe_parse_xml(response)

  if response.code =~ /^2/ && maybe_document
    nodes(maybe_document, '//consignments/consignment').each do |consignment|
      print('% 15.15s % 20.20s %s %- 10.10s % 15.15s' % %w[name address1 country postcode city].map{|a| content consignment, "addresses/address[@type=\"ConsigneeAddress\"]/#{a}" })
      puts(' % 10.10s % 10.10s' % [content(consignment, 'transport-agreement/carrier/name'), content(consignment, 'product/name')])
    end
  else
    inspect_response response
  end


end
