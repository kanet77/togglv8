#! /usr/bin/env rvm ruby-1.9.3-head do ruby

require_relative 'togglV8'

tog = Toggl.new
# tog.debug

# tog = Toggl.new(toggl_api_key)
# tog = Toggl.new(username, password)
# tog = Toggl.new('4p2hx5sfvb@snkmail.com') # ERROR

def print_projects(tog)
  ws = tog.workspaces
  ws.each do |w|
    wid = w['id']
    @wname=w['name']

    tp = Hash.new
    ts = tog.tasks(wid)
    ts.each do |t|
      tp[t['pid']] = t['name']
    end

    ps = tog.projects(wid)
    ps.each do |p|
      @pname = p['name']
      @tname = tp[p['id']] ? ' (' + tp[p['id']] + ")" : ''
      puts "#@wname - #@pname#@tname"
    end

    us = tog.users(wid)
    us.each do |u|
      @uname = u['fullname'] + "/" + u['email']
      puts "#@wname : #@uname"
    end
  end
end

if __FILE__ == $0
  ap tog.me
  # ap tog.me(:all)
  print_projects(tog)
  # tog.create_project({:name => "HUGE project", :wid => "282224"})
end