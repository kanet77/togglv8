require 'rubygems'
require 'httparty'

class Representative
  include HTTParty
  # format :xml

  def initialize(fmt)
    self.class.format fmt
  end

  def self.find_by_zip(zip)
    get('http://whoismyrepresentative.com/whoismyrep.php', :query => {:zip => zip})
  end
end

r = Representative.new(:xml)

puts r.find_by_zip(78751).inspect