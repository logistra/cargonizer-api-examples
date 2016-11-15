require 'net/http'
require 'uri'
require 'nokogiri'

URL = URI.parse('https://cargonizer.no')
#URL = URI.parse('http://staging.cargonizer.no')
KEY = '1234567890abcdef'
SENDER = '123'
USER_AGENT = 'MyApp'


def request(method, path, opts={})
  path = "/#{path}" unless path.start_with?('/')
  path = "#{path}?#{opts[:params].map{|k,v| "#{k}=#{v}" }.join('&')}" if opts[:params]

  headers = {'Content-Type': 'application/xml', 'Accept': 'application/xml', 'User-Agent': USER_AGENT, 'X-Cargonizer-Key': KEY, 'X-Cargonizer-Sender': SENDER}
  headers.update(opts[:headers]) if opts[:headers]

	Net::HTTP.start URL.host, URL.port, nil, nil, nil, nil, use_ssl: URL.scheme == 'https' do |http|
		request = Net::HTTP.const_get(method.to_s.capitalize).new(path)
    headers.each do |key, value|
      request[key] = value
    end
		request.body = opts[:body] if opts[:body]
		http.request(request)
	end
end

%w[get post put delete patch].each do |method|
  define_method method do |*args|
    request method.upcase, *args
  end
end

def inspect_response(response)
  puts "#{response.code} #{response.message}"
  response.each_header{|k,v| puts "#{k}: #{v}" }
  puts
	if document = maybe_parse_xml(response)
    puts document.to_xml
  else
    puts response.body
  end
end

def maybe_parse_xml(response)
	if response['Content-Type'] =~ /xml/i
		Nokogiri::XML.parse(response.body) rescue nil
	else
		nil
	end
end

def nodes(node, xpath)
  node.xpath(xpath)
end

def content(node, xpath)
  child = node.at_xpath(xpath)
  child && child.content
end
