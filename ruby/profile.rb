require_relative 'utils'

response = get '/profile.xml'
maybe_document = maybe_parse_xml response

if response.code =~ /^2/ && maybe_document
  puts maybe_document.to_xml
else
  inspect_response response
end
