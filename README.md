
# Toggl API v8

[![Build Status](https://api.travis-ci.org/kanet77/togglv8.svg "Build Status")](https://travis-ci.org/kanet77/togglv8) [![Coverage Status](https://coveralls.io/repos/kanet77/togglv8/badge.svg?branch=master&service=github)](https://coveralls.io/github/kanet77/togglv8?branch=master)

[Toggl](http://www.toggl.com) is a time tracking tool.

[togglv8](/) is a Ruby Wrapper for [Toggl API v8](https://github.com/toggl/toggl_api_docs). It is designed to mirror the Toggl API as closely as possible.

**Note:** Currently togglv8 only includes calls to [Toggl API](https://github.com/toggl/toggl_api_docs/blob/master/toggl_api.md), not the [Reports API](https://github.com/toggl/toggl_api_docs/blob/master/reports.md)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'togglv8'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install togglv8

## Usage

This short example shows one way to create a time entry for the first workspace of the user identified by `<API_TOKEN>`:

```ruby
require 'togglv8'

toggl_api    = TogglV8::API.new(<API_TOKEN>)
user         = toggl_api.me(all=true)
workspaces   = toggl_api.my_workspaces(user)
workspace_id = workspaces.first['id']
toggl_api.create_time_entry({
  'description' => "Workspace time entry",
  'wid' => workspace_id,
  'duration' => 1200,
  'start' => "2015-08-18T01:13:40.000Z",
  'created_with' => "My awesome Ruby application"
})
```

See specs for more examples.

**Note:** Requests are rate-limited. The togglv8 gem will handle a 429 response by pausing for 1 second and trying again, for up to 3 attempts. See [Toggl API docs](https://github.com/toggl/toggl_api_docs#the-api-format):

> For rate limiting we have implemented a Leaky bucket. When a limit has been hit the request will get a HTTP 429 response and it's the task of the client to sleep/wait until bucket is empty. Limits will and can change during time, but a safe window will be 1 request per second. Limiting is applied per api token per IP, meaning two users from the same IP will get their rate allocated separately.

## Debugging

The `TogglV8::API#debug` method determines if debug output is printed to STDOUT. (The default is `true`.) This code snippet demonstrates the debug output.

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
