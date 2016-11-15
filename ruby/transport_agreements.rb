require_relative 'utils'

response = get '/transport_agreements.xml'
maybe_document = maybe_parse_xml(response)

if response.code =~ /^2/
  if maybe_document
    if false
      puts maybe_document.to_xml
    else
      #Display a simple overview of transport agreements with products and services
      nodes(maybe_document, '//transport-agreements/transport-agreement').each do |agreement|
        puts "Transport agreement: #{content(agreement, 'id')} with #{content(agreement, 'carrier/name')}"
        agreement.xpath('products/product').each do |product|
          puts "  `- Product: #{content(product, 'name')} (#{content(product, 'identifier')})"
          nodes(product, 'services/service').each do |service|
            puts "    `- Service: #{content(service, 'name')} (#{content(service, 'identifier')})"
          end
        end
      end
    end
  else
    puts "Could not parse response:\n\n#{response.body}"
  end
else
  inspect_response response
end
