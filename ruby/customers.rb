require_relative 'utils'

if true # Get customers

  response = get '/customers.xml'
  maybe_document = maybe_parse_xml(response)

  if response.code =~ /^2/ && maybe_document
    nodes(maybe_document, '//customers/customer').each do |customer|
      puts("% 10s %30.30s % 30.30s %s %- 10.10s %15.15s" % %w[number name address1 country postcode city].map{|a| content customer, a })
    end
  else
    inspect_response response
  end

else # Create customer

  document = Nokogiri::XML::Builder.new encoding: 'UTF-8' do |xml|
    xml.customer do
      xml.name 'Ronald McDonald'
      xml.address1 '123 Peripheral Vision St'
      xml.country 'US'
      xml.postcode '12345'
      xml.city 'Philadelphia'
      xml.email 'badass32@tacticalbeer.com'
    end
  end

  response = post '/customers.xml', body: document.to_xml
  maybe_document = maybe_parse_xml response
  inspect_response response

end
