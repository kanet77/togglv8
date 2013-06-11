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

  # tasks = []
  # ts = tog.tasks(282224)
  # ts.each do |t|
  #   # tp[t['pid']] << t['name']
  #   # tasks.push(t["id"])
  #   puts t
  # end
  # # ap tasks
  # # tog.delete_task(1893146)
  # ap tog.get_task(1893146)
end