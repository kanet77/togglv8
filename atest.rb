#! /usr/bin/env rvm ruby-1.9.3-head do ruby
# encoding: utf-8

require_relative 'togglV8'
require 'time'

tog = Toggl.new

if __FILE__ == $0
  te = tog.get_time_entries(Time.new(2012, 1, 1))
  te.each do |t|
    puts "#{t['wid']} #{t['description']} #{t['id']}"
  end

  tp = {}
  ts = tog.tasks(282224)
  ts.each do |t|
    tp[t['id']] = t['name']
    # puts t
  end
  ap tp
end