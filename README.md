
# Toggl API v8

[![Gem Version](https://badge.fury.io/rb/togglv8.svg)](https://badge.fury.io/rb/togglv8) [![Build Status](https://api.travis-ci.org/kanet77/togglv8.svg "Build Status")](https://travis-ci.org/kanet77/togglv8) [![Coverage Status](https://coveralls.io/repos/kanet77/togglv8/badge.svg?branch=master&service=github)](https://coveralls.io/github/kanet77/togglv8?branch=master) [![Code Climate](https://codeclimate.com/github/kanet77/togglv8/badges/gpa.svg)](https://codeclimate.com/github/kanet77/togglv8)

[Toggl](http://www.toggl.com) is a time tracking tool.

[togglv8](/) is a Ruby Wrapper for [Toggl API v8](https://github.com/toggl/toggl_api_docs). It is designed to mirror the Toggl API as closely as possible.

togglv8 supports both [Toggl API](https://github.com/toggl/toggl_api_docs/blob/master/toggl_api.md) and [Reports API](https://github.com/toggl/toggl_api_docs/blob/master/reports.md)

## Change Log

See [CHANGELOG](CHANGELOG.md) for a summary of notable changes in each version.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'togglv8'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install togglv8

## Initialization

### TogglV8::API

TogglV8::API communicates with [Toggl API v8](https://github.com/toggl/toggl_api_docs/blob/master/toggl_api.md) and can be initialized in one of three ways.

```ruby
TogglV8::API.new                      # reads API token from file ~/.toggl
TogglV8::API.new(api_token)           # explicit API token
TogglV8::API.new(email, password)     # email & password
```

### TogglV8::ReportsV2

TogglV8::ReportsV2 communicates with [Toggl Reports API v2](https://github.com/toggl/toggl_api_docs/blob/master/reports.md) and can be initialized in one of three ways. Toggl.com requires authentication with an API token for Reports API v2.

```ruby
TogglV8::ReportsV2.new                              # reads API token from file ~/.toggl
TogglV8::ReportsV2.new(toggl_api_file: toggl_file)  # reads API token from toggl_file
TogglV8::ReportsV2.new(api_token: api_token)        # explicit API token
```

**Note:** `workspace_id` must be set in order to generate reports.

```ruby
toggl = TogglV8::API.new
reports = TogglV8::ReportsV2.new
reports.workspace_id = toggl.workspaces.first['id']
```

## Usage

This short example shows one way to create a time entry for the first workspace of the user identified by `<API_TOKEN>`. It then generates various reports containing that time entry.

```ruby
require 'togglv8'
require 'json'

toggl_api    = TogglV8::API.new(<API_TOKEN>)
user         = toggl_api.me(all=true)
workspaces   = toggl_api.my_workspaces(user)
workspace_id = workspaces.first['id']
time_entry   = toggl_api.create_time_entry({
  'description' => "My awesome workspace time entry",
  'wid' => workspace_id,
  'duration' => 1200,
  'start' => toggl_api.iso8601((Time.now - 3600).to_datetime),
  'created_with' => "My awesome Ruby application"
})

begin
  reports               = TogglV8::ReportsV2.new(api_token: <API_TOKEN>)
  begin
    reports.summary
  rescue Exception => e
    puts e.message      # workspace_id is required
  end
  reports.workspace_id  = workspace_id
  summary               = reports.summary
  puts "Generating summary JSON..."
  puts JSON.pretty_generate(summary)
  puts "Generating summary PDF..."
  reports.write_summary('toggl_summary.pdf')
  puts "Generating weekly CSV..."
  reports.write_weekly('toggl_weekly.csv')
  puts "Generating details XLS..."
  reports.write_details('toggl_details.xls')
  # Note: toggl.com does not generate Weekly XLS report (as of 2016-07-24)
ensure
  toggl_api.delete_time_entry(time_entry['id'])
end
```

See specs for more examples.

**Note:** Requests are rate-limited. The togglv8 gem will handle a 429 response by pausing for 1 second and trying again, for up to 3 attempts. See [Toggl API docs](https://github.com/toggl/toggl_api_docs#the-api-format):

> For rate limiting we have implemented a Leaky bucket. When a limit has been hit the request will get a HTTP 429 response and it's the task of the client to sleep/wait until bucket is empty. Limits will and can change during time, but a safe window will be 1 request per second. Limiting is applied per api token per IP, meaning two users from the same IP will get their rate allocated separately.

## Debugging

The `TogglV8::API#debug` method determines if debug output is printed to STDOUT. This code snippet demonstrates the debug output.

```ruby
require 'togglv8'

toggl = TogglV8::API.new

toggl.debug(true)  # or simply toggl.debug
user1 = toggl.me
puts "user: #{user1['fullname']}, debug: true"

puts '-'*80

toggl.debug(false)
user2 = toggl.me
puts "user: #{user2['fullname']}, debug: false"
```

## Documentation

Run `rdoc` to generate documentation. Open `doc/index.html` in your browser.

Also available on [DocumentUp](https://documentup.com/kanet77/togglv8)

## Acknowledgements

- Thanks to the following contributors (in alphabetical order):
    * [archonic](https://github.com/archonic) ([fork](https://github.com/archonic/togglv8))
    * [ddiatmb](https://github.com/ddiatmb) ([fork](https://github.com/ddiatmb/togglv8))
    * [itaymendel](https://github.com/itaymendel)
    * [ppawlikmb](https://github.com/ppawlikmb) ([fork](https://github.com/ppawlikmb/togglv8))
    * [worldsmithroy](https://github.com/worldsmithroy) ([fork](https://github.com/worldsmithroy/togglv8))
- Thanks to [Koen Van der Auwera](https://github.com/atog) for the [Ruby Wrapper for Toggl API v6](https://github.com/atog/toggl)
- Thanks to the Toggl team for exposing the API.

## Contributing

1. Fork it ( https://github.com/kanet77/togglv8/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Pull Requests that include tests are **much** more likely to be accepted and merged quickly.

## License

Copyright (c) 2013-2016 Tom Kane. Released under the [MIT License](http://opensource.org/licenses/mit-license.php). See [LICENSE.txt](LICENSE.txt) for details.
