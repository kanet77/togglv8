# Change Log

Notable changes are documented here following conventions outlined at [Keep a CHANGELOG](http://keepachangelog.com/).

Changes that are not intended to affect usage (e.g. documentation, specs, removal of dead code, etc.) are generally not documented here.

Version numbers are meant to adhere to [Semantic Versioning](http://semver.org/).


## [Unreleased]


## [1.2.0] - 2016-07-24
### Added

* Add support for [Toggl Reports API v2](https://github.com/toggl/toggl_api_docs/blob/master/reports.md).


## [1.1.0] - 2016-02-22
### Added

* Add `tags(workspace_id)`.


## [1.0.5] - 2016-02-22
### Added

* Add specs for encoding of ISO8601 times with + UTC offset. (See [1.0.4](#104---2016-01-22))


## [1.0.4] - 2016-01-22
### Fixed

* Manually encode `+` to `%2B` before every API call. (Fixes #11)


## [1.0.3] - 2016-01-22
### Added

* Add `debug()` method to enable debugging output including full API response.

## [1.0.2] - 2015-12-12
### Changed

* Require params 'tags' and 'tag_action' in `update_time_entries_tags()`.

## [1.0.1] - 2015-12-10
### Fixed

* Fix Toggl API call in `get_project_tasks()`. (Fixes #5)

### Added

* Add `my_tasks()`.
* Add null checks to various methods.

### Changed

* Require params 'name' and 'pid' in `create_task()`.

## [1.0.0] - 2015-12-06
### Added

* Add `my_deleted_projects()`.

### Changed

* Exclude deleted projects from `my_projects()` results.
* Change `get_time_entries()` parameters.
    - old: `start_timestamp=nil, end_timestamp=nil`
    - new: `dates = {}`
* Raise RuntimeError w/ HTTP Status code if request is not successful.
* Handle 429 (Too Many Requests) by pausing for 1 second and retrying up to 3 times.
    - API calls are limited to 1/sec due to toggl.com limits
* Refactor duplication out of GET/POST/PUT/DELETE API calls.

## [0.2.0] - 2015-08-21
### Added

* Add Ruby interface to most functions of [Toggl V8 API](https://github.com/toggl/toggl_api_docs/blob/master/toggl_api.md) (as of 2015-08-21).


[Unreleased]: https://github.com/kanet77/togglv8/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/kanet77/togglv8/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/kanet77/togglv8/compare/v1.0.5...v1.1.0
[1.0.5]: https://github.com/kanet77/togglv8/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/kanet77/togglv8/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/kanet77/togglv8/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/kanet77/togglv8/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/kanet77/togglv8/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/kanet77/togglv8/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/kanet77/togglv8/compare/a1d5cc5...v0.2.0