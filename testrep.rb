require_relative 'reportsV2'
require 'awesome_print'
require 'time'

rep = TogglReports.new

if __FILE__ == $0
  rep.debug_on

  h = { "since" => "2013-11-10", "until" => "2013-11-16" }
  ap rep.summary(460285,h)
end
