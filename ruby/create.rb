require 'rubygems'
require 'httparty'

# Cargonizer API example - create a consignment
#
# This is not production quality code, just a very simple example. Read XML file,
# send to Cargonizer with appropriate authentication headers.


#API key
key = '123456789'
managership = '123'

xml = File.read('consignment.xml')

puts "INPUT XML:\n\n"
puts xml

class Foo
  include HTTParty
  parser lambda{|d,e| d}
end

puts "\n\nOUTPUT XML:\n\n"

puts Foo.post('http://cargonizer.no/consignments',
  :headers => {'X-Cargonizer-Key' => key, 'Content-Type' => 'application/xml', 'Accept' => 'application/xml', 'X-Cargonizer-Sender' => managership},
  :body => xml
)
