require 'rubygems'
require 'httparty'

class Twitter
  include HTTParty
  base_uri 'twitter.com'

  def initialize(user, pass)
    self.class.basic_auth user, pass
  end

  def post(text)
    self.class.post('/statuses/update.json', :query => {:status => text})
  end
end

t = Twitter.new('username', 'password')
puts t.post("It's an HTTParty and everyone is invited!").inspect
