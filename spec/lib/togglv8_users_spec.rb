require_relative '../../lib/togglv8'
require 'oj'

describe Toggl do
  before :all do
    @toggl = Toggl::V8.new('4880adbe1bee9a241fa08070d33bd49f')
    @user = @toggl.me(all=true)
  end

  it 'can return /me' do
    expect(@user).to_not be_nil
    expect(@user['id']).to eq 1820939
    expect(@user['fullname']).to eq 'togglv8'
    expect(@user['default_wid']).to eq 1060392
    expect(@user['image_url']).to eq 'https://assets.toggl.com/avatars/a5d106126b6bed8df283e708af0828ee.png'
    expect(@user['timezone']).to eq 'Etc/UTC'
    expect(@user['workspaces'].length).to eq 1
    expect(@user['workspaces'].first['name']).to eq "togglv8's workspace"
  end

  it 'can return /my_clients' do
    my_clients = @toggl.my_clients(@user)
    expect(my_clients).to be nil
  end

  it 'can return /my_projects' do
    my_projects = @toggl.my_projects(@user)
    expect(my_projects).to be nil
  end

  it 'can return /my_tags' do
    my_tags = @toggl.my_tags(@user)
    expect(my_tags).to be nil
  end

  it 'can return /my_time_entries' do
    my_time_entries = @toggl.my_time_entries(@user)
    expect(my_time_entries).to be nil
  end

  it 'can return /my_workspaces' do
    my_workspaces = @toggl.my_workspaces(@user)
    expect(my_workspaces.length).to eq 1
  end

end