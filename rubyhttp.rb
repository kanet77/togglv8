#!/usr/bin/env  rvm 1.9 do ruby

require 'net/http'

url = URI.parse('http://www.example.com/index.html')
req = Net::HTTP::Get.new(url.path)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}
puts res.body