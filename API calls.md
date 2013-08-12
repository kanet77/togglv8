# Toggl v8 API calls

These API calls with [curl](http://curl.haxx.se/) were useful when prototyping togglv8.

The calls have since been converted to use [resty](https://github.com/micha/resty) (a wrapper for curl). They are included here only for reference.

See [Toggl API Documentation](https://github.com/toggl/toggl_api_docs) for more authoritative, comprehensive, and up-to-date information.

As of 2013-08-11, the calls listed here cover almost the entire [Toggl API](https://github.com/toggl/toggl_api_docs/blob/master/toggl_api.md) section. The following calls are not yet supported by [togglv8](/):
* [Add multiple users to a project](/API%20calls.md#add-multiple-users-to-a-project)
* [Update multiple project users](/API%20calls.md#update-multiple-project-users)
* [Delete multiple project users](/API%20calls.md#delete-multiple-project-users)
* [Sign up new user](/API%20calls.md#sign-up-new-user) (Will increase the cost of your Toggl account.)
* [Invite users to workspace](/API%20calls.md#invite-users-to-workspace)
* [Delete workspace user](/API%20calls.md#delete-workspace-user)
* [Get workspace users for a workspace](/API%20calls.md#get-workspace-users-for-a-workspace)

# Authentication

Toggl API uses Basic Auth. Resty is initialized with basic auth info (-u), as well as headers (-H).

### HTTP Basic Auth with API token
The user API Token for an account is available under [My Profile](https://www.toggl.com/user/edit) after logging into [Toggl.com](https://www.toggl.com).

When using an API Token, the user is your API Token and the password is "api_token".
```
resty https://www.toggl.com/api/v8 -u 1971800d4d82861d8f2c1651fea4d212:api_token -H "Content-type: application/json"
```

### (Alternative method) HTTP Basic Auth with e-mail and password
It is also possible to use your email address and Toggl password.
```
resty https://www.toggl.com/api/v8 -u your.email@example.com:SuperSecretPassword -H "Content-type: application/json"
```

# Displaying JSON
It is helpful to use a JSON parsing tool such as [Jazor](https://github.com/mconigliaro/jazor).

For example, ```GET /me | jazor -c``` outputs

```
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

---

# Clients

### Create client
```
POST /clients -d '{"client":{"name":"Very Big Company","wid":282224}}'
```

### Read client
```
GET /clients/1101632
```

### Update client
```
PUT /clients/1150638 -d '{"client":{"notes":"this client must go!"}}'
```

### Delete client
```
DELETE /clients/1150758
```

### Get clients visible to user
```
GET /clients
```

### Get client projects
```
GET /clients/1150488/projects
```

# Projects

### Create project
```
POST /projects -d '{"project":{"name":"TEST project","wid":282224,"is_private":true}}'
```

### Read project
```
GET /projects/2882160
```

### Update project
```
PUT /projects/2931253 -d '{"project":{"name":"Changed the name","is_private":false,"template":true}}'
```

### Get project users
```
GET /projects/2883126/project_users
```

# Project users

### Create project user
```
POST /project_users -d '{"project_user":{"pid":2931296,"uid":509726,"rate":30.0,"manager":true}}'
```

### Update project user
```
PUT /project_users/8310314 -d '{"project_user":{"manager":false,"rate":15,"fields":"fullname"}}'
```

### Delete project user
```
DELETE /project_users/8310314
```
### Add multiple users to a project
**Note:** Not yet supported by [togglv8](/)

### Update multiple project users
**Note:** Not yet supported by [togglv8](/)

### Delete multiple project users
**Note:** Not yet supported by [togglv8](/)

# Tags

### Create tag
```
POST /tags -d '{"tag":{"name":"tag"}}'
```

### Update tag
```
PUT /tags/294414 -d '{"tag":{"name":"taggggg"}}'
```

### Delete tag
```
DELETE /tags/294414
```

# Tasks

### Create task
```
POST /tasks -d '{"task":{"name":"A new task","pid":2883129}}'
```

### Get task details
```
GET /tasks/1894675
```

### Update task
```
PUT /tasks/1894675 -d '{"task":{"id": 1894675, "active": true, "estimated_seconds": 7200, "fields": "done_seconds,uname"}}'
```

### Delete task
```
DELETE /tasks/1893464
```

### Update multiple tasks
```
PUT /tasks/1894758,1894751 -d '{"task":{"active":false,"fields":"done_seconds,uname"}}'
```

### Delete multiple Tasks
```
DELETE /tasks/1922656,1922683,1922684
```

# Time entries

### Create time entry
```
POST /time_entries -d '{"time_entry":{"description":"Meeting with possible clients","tags":["billed"],"duration":1200,"start":"2013-03-05T07:58:58.000Z","pid":2931296}}'
```

### Get time entry details
```
GET /time_entries/77628973
```

### Start a time entry
```
POST /time_entries/start -d '{"time_entry":{"description":"New time entry","wid":282224}}'
```

### Stop a time entry
```
PUT /time_entries/86229778/stop
```

### Update time entry
```
PUT /time_entries/86229778 -d '{"time_entry":{"description":"Renamed new time entry","duration":180}}'
```

### Delete time entry
```
DELETE /time_entries/86229778
```

### Get time entries started in a specific time range
**Note:**

- `start_date` and `end_date` are in [ISO 8601 date and time format](http://en.wikipedia.org/wiki/ISO_8601#Combined_date_and_time_representations), (e.g. "2013-03-10T15:42:46+02:00")
- It is necessary to use the encoded value %2B for '+' in order to avoid JSON parsing error. (Using %3A for ':' is not strictly necessary.)

```
GET /time_entries -q 'start_date=2013-05-22T15:42:46%2B02:00&end_date=2013-05-22T16:42:46%2B02:00'
```

```
GET /time_entries -q 'start_date=2013-06-04T18:32:12%2B00:00'
```

# Users

### Get current user data
```
GET /me
```

### Get current user with related data
```
GET /me?with_related_data=true -Q
```
or
```
GET /me -q 'with_related_data=true'
```

### Sign up new user
**Note:** This is not implemented in [togglv8](/) wrapper because it  will increase the cost of your Toggl account. See [Toggl Pricing and Payments](http://support.toggl.com/pricing-and-payments/) for details.
```
POST /signups -d '{"user":{"email":"<email_address>","password":"<password>"}}'
```

# Workspaces

### Get user workspaces
```
GET /workspaces
```

### Get workspace users
```
GET /workspaces/282224/users
```

### Get workspace clients
```
GET /workspaces/282224/clients
```

### Get workspace projects
```
GET /workspaces/282224/projects
```

### Get workspace tasks
```
GET /workspaces/282224/tasks
```
```
GET /workspaces/282224/tasks?active=true
```
```
GET /workspaces/282224/tasks?active=false
```
```
GET /workspaces/282224/tasks?active=both
```

# Workspace Users

### Invite users to workspace
**Note:** Not yet supported by [togglv8](/)

### Update workspace user (can only update admin flag)
**Note:** Call fails with error message "Cannot access workspace users"
```
PUT /workspace_users/282224 -d '{"workspace_user":{"admin":true}}'
```

### Delete workspace user
**Note:** Not yet supported by [togglv8](/)

### Get workspace users for a workspace
**Note:** Not yet supported by [togglv8](/)
