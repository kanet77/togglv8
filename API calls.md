# Toggl v8 API calls

These API calls with `curl` were useful when prototyping togglv8. They are included here only for reference.

See [Toggl API Documentation](https://github.com/toggl/toggl_api_docs) for more authoritative, comprehensive, and up-to-date information.

As of 2013-06-14, the calls listed here cover almost the entire [Toggl API](https://github.com/toggl/toggl_api_docs/blob/master/toggl_api.md) section.

### Authentication

Access to Toggl API requires an API token. The user API Token for an account is available under [My Profile](https://www.toggl.com/user/edit) after logging into [Toggl.com](https://www.toggl.com).

In the curl commands listed below, `$(toggl_api)` must be replaced with the Toggl API token. One way to do this (rather than copying and pasting the API token every time) is to store the API token in a file and define an alias that prints out the contents of that file. (`$(toggl_api)` calls the )

 - file `~/.toggl` contains `<api_token>`
 - `alias toggl_api='cat ~/.toggl'`

To instead authenticate with usernamd and password, replace `$(toggl_api):api_token` with `$(toggl_up)` and create the following file and alias.

 - file `~/.toggl_up` contains `<email_address>:<password>`
 - `alias toggl_up='cat ~/.toggl_up'`

### Displaying JSON
It is helpful to use a JSON parsing tool such as [Jazor](https://github.com/mconigliaro/jazor).

For example, ```curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/me | jazor -c``` outputs

```json
{
  since: 1370938972,
  data: {
    id: {<user_id>},
    api_token: "<api_token>",
    default_wid: <wid>,
    email: "<email_address>",
    fullname: "<fullname>",
    jquery_timeofday_format: H:i,
    jquery_date_format: "m/d/Y",
    timeofday_format: H:mm,
    date_format: "MM/DD/YYYY",
    store_start_and_stop_time: true,
    beginning_of_week: 1,
    language: "en_US",
    image_url: https://www.toggl.com/system/avatars/<image.jpg>,
    sidebar_piechart: false,
    at: "2013-06-11T07:00:44+00:00",
    created_at: "2012-08-01T12:41:56+00:00",
    retention: 9,
    record_timeline: true,
    render_timeline: true,
    timeline_enabled: true,
    timeline_experiment: true,
    manual_mode: true,
    new_blog_post: {
    },
    invitation: {
    }
  }
}
```

rather than

```
{"since":1370938972,"data":{"id":<user_id>},"api_token":"<api_token>","default_wid":<wid>,"email":"<email_address>","fullname":"<fullname>","jquery_timeofday_format":"H:i","jquery_date_format":"m/d/Y","timeofday_format":"H:mm","date_format":"MM/DD/YYYY","store_start_and_stop_time":true,"beginning_of_week":1,"language":"en_US","image_url":"https://www.toggl.com/system/avatars/<image.jpg>","sidebar_piechart":false,"at":"2013-06-11T07:00:44+00:00","created_at":"2012-08-01T12:41:56+00:00","retention":9,"record_timeline":true,"render_timeline":true,"timeline_enabled":true,"timeline_experiment":true,"manual_mode":true,"new_blog_post":{},"invitation":{}}}
```

# Authenticate and get user data

Toggl API uses Basic Auth via `curl -u <user:password>`.
When using an API Token, the user is your API Token and the password is "api_token".
It is also possible to use your email address and Toggl password.

### HTTP Basic Auth with API token
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/me
```

### (Alternative method) HTTP Basic Auth with e-mail and password
```
curl -u $(toggl_up) -X GET https://www.toggl.com/api/v8/me
```
### Authentication with a session cookie
#### Create and save session cookie
```
curl -v -u $(toggl_api):api_token -X POST https://www.toggl.com/api/v8/sessions -c toggl_api_session.cookie
```

#### Use session cookie
```
curl -b toggl_api_session.cookie -X GET https://www.toggl.com/api/v8/me
```

#### Destroy session
```
curl -b toggl_api_session.cookie -X DELETE https://www.toggl.com/api/v8/sessions
```

# User data

### Basic user data
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/me
```
### Additional user data: Clients, Projects, Tags, Time Entries, Workspaces, etc.
```
curl -u $(toggl_api):api_token -H "Content-type: application/json" -X GET https://www.toggl.com/api/v8/me?with_related_data=true
```

# Clients

### Create client
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"client":{"name":"Very Big Company","wid":282224}}' \
    -X POST https://www.toggl.com/api/v8/clients
```

### Read client
```
curl -u $(toggl_api):api_token \
    -X GET https://www.toggl.com/api/v8/clients/1101632
```

### Update client
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"client":{"notes":"this client must go!"}}' \
    -X PUT https://www.toggl.com/api/v8/clients/1150638
```

### Delete client
```
curl -v -u $(toggl_api):api_token \
    -X DELETE https://www.toggl.com/api/v8/clients/1150758
```

### Get clients visible to user
```
curl -u $(toggl_api):api_token \
    -X GET https://www.toggl.com/api/v8/clients
```

### Get client projects
```
curl -u $(toggl_api):api_token \
    -X GET https://www.toggl.com/api/v8/clients/1150488/projects
```

# Projects

### Create project
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"project":{"name":"TEST project","wid":282224,"is_private":true}}' \
    -X POST https://www.toggl.com/api/v8/projects
```

### Read project
```
curl -u $(toggl_api):api_token -H "Content-type: application/json" \
    -X GET https://www.toggl.com/api/v8/projects/2882160
```

### Update project
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"project":{"name":"Changed the name","is_private":false,"template":true}}' \
    -X PUT https://www.toggl.com/api/v8/projects/2931253
```

### Get project users
```
curl -u $(toggl_api):api_token \
    -X GET https://www.toggl.com/api/v8/projects/2883126/project_users
```

# Project users

### Create project user
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"project_user":{"pid":2931296,"uid":509726,"rate":30.0,"manager":true}}' \
    -X POST https://www.toggl.com/api/v8/project_users
```

### Update project user
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"project_user":{"manager":false,"rate":15,"fields":"fullname"}}' \
    -X PUT https://www.toggl.com/api/v8/project_users/8310314
```

### Delete project user
```
curl -u $(toggl_api):api_token \
    -X DELETE https://www.toggl.com/api/v8/project_users/8310314
```

# Tags

### Create tag
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"tag":{"name":"tag"}}' \
    -X POST https://www.toggl.com/api/v8/tags
```

### Update tag
```
curl -v -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"tag":{"name":"taggggg"}}' \
    -X PUT https://www.toggl.com/api/v8/tags/294414
```

### Delete tag
```
curl -v -u $(toggl_api):api_token \
    -X DELETE https://www.toggl.com/api/v8/tags/294414
```

# Tasks

### Create task
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"task":{"name":"A new task","pid":2883129}}' \
    -X POST https://www.toggl.com/api/v8/tasks
```

### Get task details
```
curl -u $(toggl_api):api_token \
    -X GET https://www.toggl.com/api/v8/tasks/1894675
```

### Update task
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"task":{"id": 1894675, "active": true, "estimated_seconds": 7200, "fields": "done_seconds,uname"}}' \
    -X PUT https://www.toggl.com/api/v8/tasks/1894675
```

### Delete task
```
curl -u $(toggl_api):api_token \
    -X DELETE https://www.toggl.com/api/v8/tasks/1893464
```

### Update multiple tasks
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"task":{"active":false,"fields":"done_seconds,uname"}}' \
    -X PUT https://www.toggl.com/api/v8/tasks/1894758,1894751
```

### Delete multiple Tasks
```
curl -u $(toggl_api):api_token \
    -X DELETE https://www.toggl.com/api/v8/tasks/1922656,1922683,1922684
```

# Time entries

### Create time entry
```
curl -v -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"time_entry":{"description":"Meeting with possible clients","tags":["billed"],"duration":1200,"start":"2013-03-05T07:58:58.000Z","pid":2931296}}' \
    -X POST https://www.toggl.com/api/v8/time_entries
```

### Get time entry details
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/time_entries/77628973
```

### Update time entry
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"time_entry":{"description":"Meeting ALL THE clients","tags":[""],"duration":1240,"start":"2013-06-08T07:58:58.000Z","stop":"2013-06-08T08:58:58.000Z","duronly":true,"billable":false}}' \
    -X PUT https://www.toggl.com/api/v8/time_entries/77633781
```

### Get time entries started in a specific time range
**Notes:**

- `start_date` and `end_date` are in ISO 8601 format, (e.g. "2013-03-10T15:42:46+02:00")
- It is necessary to use the encoded value %2B for '+' in order to avoid JSON parsing error. (Using %3A for ':' is not strictly necessary.)

```
curl -u $(toggl_api):api_token \
    -X GET "https://www.toggl.com/api/v8/time_entries?start_date=2013-05-22T15%3A42%3A46%2B02%3A00&end_date=2013-05-22T16%3A42%3A46%2B02%3A00"
```

```
curl -u $(toggl_api):api_token \
    -X GET "https://www.toggl.com/api/v8/time_entries?start_date=2013-06-04T18:32:12%2B00:00"
```

### Delete time entry
```
curl -u $(toggl_api):api_token -X DELETE https://www.toggl.com/api/v8/time_entries/77628973
```

# Users

### Sign up new user
**Notes:** This is not implemented in [togglv8](/) wrapper because it  will increase the cost of your Toggl account. See [Toggl Pricing and Payments](http://support.toggl.com/pricing-and-payments/) for details.
```
curl -H "Content-type: application/json" \
    -d '{"user":{"email":"<email_address>","password":"<password>"}}' \
    -X POST https://www.toggl.com/api/v8/signups
```

# Workspaces

### Get user workspaces
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces
```
  or
```
curl -b toggl_api_session -X GET https://www.toggl.com/api/v8/workspaces
```

### Get workspace users
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/users
```

### Get workspace clients
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/clients
```

### Get workspace projects
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/projects
```

### Get workspace tasks
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/tasks
```
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/tasks?active=true
```
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/tasks?active=false
```
```
curl -u $(toggl_api):api_token -X GET https://www.toggl.com/api/v8/workspaces/282224/tasks?active=both
```

# Workspace Users

### Update workspace user (can only update admin flag)
**Note:** Call fails with error message "Cannot access workspace users"
```
curl -u $(toggl_api):api_token \
    -H "Content-type: application/json" \
    -d '{"workspace_user":{"admin":true}}' \
    -X PUT https://www.toggl.com/api/v8/workspace_users/282224
```
