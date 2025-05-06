## 3.6.0 - 2025-05-06
- Add support for Amazon ads (#59)
- profile: view repository commits on summary tap
- commits: add repository filter
- work_items: handle mentions in markdown comments
- Add share extension (#58)

## 3.5.0 - 2025-04-22
- msal: fix signout when token expired
- work_items: handle PR links in comment
- html_widget: handle tap on links with trailing slash
- pull_requests: fix work item links in description
- commits: improve tags UI

## 3.4.1 - 2025-04-02
- update msal plugin
- ios: fix dart define build script
- boards/sprints: show actions when data is loaded
- boards/sprints: show filters when data is loaded
- work_items: handle get tags error when adding tags

## 3.4.0 - 2025-03-12
- Handle pipeline approvals (#57)
- pipelines: fix deployment jobs not showing in timeline
- boards/sprints: handle boards with more than 200 items
- project_detail: fix project id in title sometimes
- ads: show less native ads
- upgrade Flutter to 3.29.0
- msal: don't log MsalUserCancelException
- improve error logs
- ads: improve error handling and logs (3)
- fix log api error

## 3.3.0 - 2025-02-18
- ads: fix onDismiss not called when ads are disabled
- ads: improve error handling and logs (2)
- boards: show only selected projects
- msal: improve error logs
- avoid html editor not initialized exception
- boards/sprints: add search items field
- sprint: add edit item action
- boards/sprints: add type and assignee filters

## 3.2.1 - 2025-02-11
- fix backlogs api call
- ads: avoid making requests if 'Unable to obtain a JavascriptEngine' error occurs
- ads: improve error handling and logs
- project_boards: fix deserialization error

## 3.2.0 - 2025-02-07
- refactoring: make WorkItemListTile private
- refactoring: renamings
- ads: show interstitial ad on PR thread status update
- refactoring: move showInterstitialAd in AdsMixin
- refactoring: get dependencies with context extensions
- Add native ads in list pages (#55)
- board_detail: show move to column api error message
- Add support for boards and sprints (#54)
- fix unnecessary rebuild when tapping screen
- pull_requests: fix Iteration deserialization error
- purchase: fix highlight default plan on Android
- upgrade dependencies
- refactoring: remove unused code and make elements private
- work_items: show success snackbar on delete item
- pull_requests: don't try to decode empty api error message
- improve error logs
- improve logs
- fix user null after logout and login again

## 3.1.0 - 2025-01-31
- Add support for saved queries (#53)
- immediately hide confirm button on create/edit work item
- check user subscription only if logged in

## 3.0.0+69 - 2025-01-23
- theme: fix UI with systemMode and platform light mode
- settings: add privacy policy and terms of use links
- purchase: fix handle cancelled purchase on Android

## 3.0.0 - 2025-01-22
- Add ads and subscription to remove them (#52)
- pull_requests: handle 'Merging' status
- pull_requests: handle 'Limit merge types' policy
- pull_requests: fix complete PR

## 2.7.0 - 2025-01-17
- work_items: fix update identity fields after confirm edit
- msal: show account picker on login
- work_items: fix set default value to readonly fields
- work_items: handle deleted area/iteration
- handle deleted project error
- pull_requests: improve PR actions handling
- html: fix unhandled list style type

## 2.6.1 - 2025-01-13
- improve bad request error logs
- rules_checker: handle copyValue rules with empty value
- work_items: fix reset html readonly fields
- #47 fix edit work item with attachments

## 2.6.0 - 2025-01-09
- work_items: fix item null on three dots actions
- file_diff: small UI improvements
- make text selectable
- work_items: show only work items links in detail page
- work_items: add/remove links
- work_items: handle areas api error
- work_items: handle identity fields default value
- fix file diff content metadata fields null
- rm empty directory
- github_actions: update Flutter version
- use msal_auth plugin for microsoft login
- upgrade to Flutter 3.27

## 2.5.0 - 2024-10-22
- work_items: add support for adding/removing tags
- work_items: show tags in detail page
- work_items: make all html/markdown links blue underlined
- work_items: show links in history
- github_actions: update Flutter version
- upgrade to Flutter 3.24.2 and upgrade dependencies

## 2.4.0 - 2024-06-27
- fix commit message text vertically cut
- pipelines: show task/job/stage execution time in timeline
- github_actions: upgrade Flutter version
- theme: fix deprecated members and update tests
- work_items: handle markdown comments
- upgrade to Flutter 3.22.2
- updated tests with Page building test (#36)

## 2.3.0 - 2024-01-26
- fix android back button handling (2)
- upgrade to flutter 3.16.7 and upgrade dependencies
- refactoring: add AppBasePage component
- fix android back button handling
- Implement named filters (#31)
- fix material3 TabBar style
- get work item type fields faster
- fix edit work item with empty identity field
- Upgrade to Flutter 3.16.5 (#21)
- avoid clearing filters on clear cache

## 2.2.0 - 2024-01-02
- Add FUNDING.yml
- Avoid persisting filters when coming from project page for pipelines and commits. (#30)
- Fix pipeline filters bug (#28)
- pipelines: add pipeline name filter
- Fix commits filters bug (#29)
- Add project search by name (#25)
- don't persist pull requests filters when coming from project page
- don't persist work items filters when coming from project page
- fix pull requests filters when coming from project page
- fix work items filters when coming from project page
- work_items: persist categories filter
- format files
- sentry: remove msal error logs
- fix pipeline null in autorefresh timer
- fix reset work items area and iteration filters
- fix parse work item state color
- fix handle multiple identical instances in memory
- Cache: bugged dark mode (#26)
- fix work item rules deserialization error
- work_items: add 'category' filter
- fix divider on wrong line when last filter is selected
- fix navigation to create_work_item with a selected project
- filters: show selected filters first
- fix duplicate work items states

## 2.1.0 - 2023-12-18
- Persist filters to local storage (#22) 
- work_items: show types distinct by name 
- work_items: show assignee and comment count in list 
- fix filter not set when navigating from project page 
- fix tap on multiple choice filter item 
- sentry: filter out NetworkImageLoadException 
- fix custom work item error message deserialization 
- work_items: handle always required fields 
- work_items: handle identity fields 
- Add support for multiple choice filters (#13) 
- work_items: show type only if project is selected 

## 2.0.2 - 2023-12-12
- fix wrong work item types shown when project already selected 
- handle inherited processes with spaces in the name 
- Project detail test (#18) 
- Fixed splash screen (#19) 
- File detail page and Repository detail page tests implementation (#17) 
- fix changelog 

## 2.0.1 - 2023-12-11
- rules_checker: handle disallowed states
- handle work item rule condition with null field
- fix github workflow
- format files
- add github workflow
- Pipeline logs page and member detail page tests (#16)
- sentry: improve error logging
- choose_projects: make sure that there are selected projects before popping page
- fix file_diff deserialization error
- fix set work item default value if field is read-only in edit mode
- settings: show changelog

## 2.0.0 - 2023-12-05
- filters: add user search field in users filters
- projects: show all teams in a project
- search_field: fix refresh with controller
- work_items: automatically set values when creating item
- work_items: improve comment UI
- pull_requests: search pr by id and title
- Merge pull request #10 from PurpleSoftSrl/dynamic-workitems-fields 
- filters: add project search field in project filter
- profile: improve today's summary 
- refactoring: extract SearchField component

## 1.16.0 - 2023-11-28
- file_diff: improve comments UI
- pull_requests: set thread status
- code cleaning
- pull_requests: navigate to file diff from file comment
- pull_requests: add 'Assigned to' filter
- commits: fix tags deserialization error
- pull_requests: add/edit/delete comment in file
- pipelines: fix pipeline null when tapping three dots
- work_items: fix update date null
- fix commit tags deserialization error

## 1.15.0 - 2023-11-17
- work_items: persist search query like a filter
- home: add projects search field
- work_items: search items by id or title
- pull_requests: handle deleted comments
- pull_requests: handle mention in comments
- pull_requests: organize comments by thread
- pull_requests: add/edit/reply to comment
- commits: show commit tags
- improve msal error logs

## 1.14.0 - 2023-11-15
- android: upgrade kotlin version
- pipelines: show pipeline previous runs
- settings: don't show PAT
- ios: remove xcode 15 compile error workaround
- file_detail: handle api response null
- upgrade dependencies
- pipelines: stop auto refresh timer when page is not visible
- work_items: don't show 'All' area/iteration filter when creating/editing a work item
- work_items: fix areas and iterations null for a few frames
- pipeline: fix null error when api return error and pipeline is in progress
- msal: log errors on sentry

## 1.13.0 - 2023-09-28
- ios: fix compilation error on xcode 15
- work_items: fix state null in edit work item
- member_avatar: add userDescriptor null check
- work_items: fix project work item types empty
- file_diff: fix deserialization error
- work_items: add toggle to show active iterations
- work_items: show only iterations belonging to selected area's project
- work_items: reset iteration filter when project changes
- work_items: make area and iteration editable
- work_items: show area and iteration in detail page
- work_items: add iteration filter in work items page
- theme: fix checkbox background color
- work_items: add area filter in work items page

## 1.12.1 - 2023-09-12
- settings: make page visible even if getOrganizations returns 401
- pull_requests: log actions
- pull_requests: fix image file diff
- pull_requests: show abandoned draft as 'abandoned'
- pull_requests: fix some deserialization/null errors

## 1.12.0 - 2023-09-06
- commits: fix deserialization error
- work_items: fix user descriptor null
- repositories: fix file navigation after switch branch
- repositories: fix branch null in repo detail page
- pull_requests: add actions to manage pr
- popup_menu: add shadow to make actions more visible in light mode
- pull_requests: show id in list and status draft
- pull_requests: handle all status updates in history
- api_service: use SentryHttpClient
- pipelines: handle empty logs
- api_service: remove 206 special handling
- api_service: retry api call if token expired
- pull_requests: show conflicting files if any
- pipelines: handle pipeline with no logs
- pull_requests: show pr commit list
- refactoring: use switch expression to build UI in file diff page
- api_service: don't treat 201, 204 and 206 as errors
- improve changed files UI
- pull_requests: fix empty iterations
- work_items: handle pr links and mentions in comments and description
- pull_requests: fix reviewers empty during page load
- pull_requests: show changed files with file diff
- code cleaning and remove unused elements
- improve logging
- refactoring: use switch to build UI in file detail page
- pull_requests: handle work items links in description and comments
- repos: encode directory and file names
- fix sign in with microsoft on ios with authenticator app
- add sign in with microsoft
- pull_requests: show pr history with comments and iterations
- work_items: make linked work items tappable in description and comments
- pull_requests: fix deserialization error

## 1.11.0 - 2023-06-30
- router: improve pipeline logs args
- refactoring: extract popup menu component
- profile: improve UI when no commits found
- increase inactive timer duration
- work_items: show edited and removed attachments
- work_items: add attachment
- work_items: edit and delete comment
- work_items: avoid adding empty comments
- work_items: get states with fewer api calls
- work_items: unassign work item
- work_items: add 'Unassigned' filter
- work_items: fix type color null
- refactoring: move EmptyPage widget in its own file
- login: improve UI
- settings: improve switch organization
- home: handle long project names
- pipelines: handle repository null
- projects: show partially succeded pipelines in stats
- pipeline: refresh page more frequently when is running
- add firebase analytics
- settings: fix set token not changed
- try handle 206 Partial Content in project langs response
- router: use record typedefs to improve type safety and maintainability
- work_items: improve create/edit error message for inherited processes
- refactoring: add AppLogger mixin
- projects: add project stats (last 7 days)
- refactoring: extract NavigationButton component
- bottomsheets: show close icon only if dismissible
- settings: add possibility to switch organization
- work_items: show type customization in filter
- work_items: improve test types handling

## 1.10.0 - 2023-06-20
- ios: add NSPhotoLibraryUsageDescription
- work_items: pop page after creating work item
- work_items: improve add comment UI
- work_items: improve detail page UI
- work_items: add work item comment
- work_items: improve create/edit work item UI
- html_editor: improve keyboard handling
- refactoring: extract HtmlEditor component
- fix ApiService.of(context) null in LifecycleListener
- work_items: improve create/edit UI
- work_items: mention user in description
- get only aad users
- work_items: use html editor to create/edit items
- theme: fix colors with system mode light
- refactoring: use records as navigation args
- refactoring: extract methods in router
- remove unused code
- code cleaning
- choose_projects: fix untoggle project when 'select all' is toggled
- commits: get commits in slices to avoid 'too many open files' error
- fix lints
- choose_projects: fix empty page showing on toggle 'select all'
- upgrade to dart 3
- projects: fix languages deserialization error
- improve error and empty pages UI
- profile: show updated work items in today's summary
- processes: remove unused members
- commits: improve changed files UI
- commits: handle commit with no changes
- pipelines: handle pipeline with no logs
- refactoring: get commit changes in get detail api call
- refactoring: get pipeline timeline in get detail api call
- refactoring: improve bottomsheet component
- refactoring: move json deserialization in models
- work_items: improve create/edit form
- refactoring: get work item updates in get detail api call
- pipelines: fix navigation tu null repo
- work_items: download types again when changing chosen projects
- work_items: handle base64 images in descriptions
- work_items: improve description and repro steps UI

## 1.9.2 - 2023-06-05
- make work items attachments fields nullable
- add WorkItem toString
- work_items: fix project work item types null
- refactoring: use same response model for work item list and detail
- project_detail: fix team members not showing when description is present
- commit_detail: avoid redundant api call to get committer image
- work_items: fix project work item states null
- test: add some basic tests for detail pages
- refactoring: simplify navigation args in some pages
- work_items: fix deserialization error
- test: add some tests for work items and prs
- refactoring: improve datetime deserialization
- sentry: improve api error logging
- work_items: show and open attachments

## 1.9.1 - 2023-05-30
- sentry: debounce error logs
- work_items: fix update revised by id null
- work_items: fix created by id null
- work_items: get states from processes and types
- work_items: remove bypassRules
- work_items: capitalize text in keyboard
- file_diff: handle merge commits diff
- project_detail: improve member avatar UI
- file_detail: add share button

## 1.9.0 - 2023-05-23
- work_items: get only items of chosen projects
- work_items: fix 'To Do' state filter
- work_items: fix type icon not changing after edit item
- bump version
- work_items: avoid changing type for types that can't be changed
- improve filters UI
- work_items: show all types icons
- pipelines: auto refresh list until all pipelines are completed
- pipelines: fix rerun pipeline wrong branch
- check that filter is changed before calling api
- work_items: refresh page after edit/delete item
- work_items: fix some issues in create/edit items
- work_items: speed api api call to get items
- work_items: improve detail page UI
- work_items: fix edit unassigned item
- remove duplicate models
- remove some unused models and fields
- refactoring: remove unused code
- fix some default filters
- work_items: handle no work items found
- remove all unused `toJson`s
- dependencies: upgrade sentry
- improve error logging
- work_items: show all work items in list page
- repos: fix gitObjectType null
- always show user filters
- show 'me' before other users in user filters
- encode branch name in url query
- improve project filters UI
- pull_requests: improve detail page UI
- pull_requests: show project in detail page
- handle multiple pages in memory in pages filterable by project
- fix duplicate api calls when multiple pages in memory
- fix reset filters on empty page
- refactoring: rename allProject -> projectAll for consistency
- refactoring: add project filter to filter mixin
- refactoring: add filter mixin for user filters
- work_items: add assignee filter
- file_diff: fix file name not shown in deleted file
- file_diff: fix line number not incrementing after edited lines
- refactoring: extract components in file_diff page
- file_diff: show deleted files/images
- file_diff: add image comparison
- projects: navigate to work pages with project filter
- pipelines: add project filter
- avoid resetting filters on refresh page

## 1.8.2 - 2023-05-15
- member_detail: improve user not found error message
- work_items: fix history update with fields null

## 1.8.1 - 2023-05-11
- work_items: fix comment padding
- pull_requests: check member entitlements response
- ios: upgrade dependencies
- pin dependencies

## 1.8.0 - 2023-05-15
- work_items: fix extra spacing around description
- work_items: show title in change history
- improve error logging
- fix share menus on iPads an Macs
- android: allowBackup false
- pipelines: small UI improvements
- commits: fix wrong error message
- work_items: make mentions clickable
- member_detail: fix error screen
- work_items: swap history items order
- home: fix reset projects on api error
- choose_projects: fix error screen
- home: improve UI with no projects
- work_items: show images full screen on tap
- refactoring: extract component HtmlWidget
- work_items: show item id in list page
- work_items: show change history
- work_items: show repro steps
- work_items: show images in item description

## 1.7.0 - 2023-05-03
- sentry: log session after 5 seconds
- pipeline: share logs
- add some other toString()s
- pipelines: auto refresh pipeline detail page if in progress
- add some toString()s
- sentry: avoid logging unauthorized errors
- remove error snackbar on unauthorized api response
- add in app review
- sentry: set screenshots quality medium
- sentry: improve overlay navigation breadcrumbs
- show api response error message in error page
- avoid throwing exception if user can't see project images
- projects: improve project detail error screen

## 1.6.2 - 2023-04-27
- home: fix double api call to get projects
- fix pipelines and commits error screens
- show user filters only if there are at least 2 users
- projects: show repositories header only if there are repos
- profile: fix error screen
- sentry: avoid logging network exceptions
- fix call getUsers when not logged in yet
- sentry: avoid logging network images exceptions
- work_items: fix assigned to links null
- settings: improve page UI
- sentry: improve navigation breadcrumbs

## 1.6.1 - 2023-04-17
- sentry: improve breadcrumbs
- pipelines: fix repo name null
- work_items: fix microsoftVstsCommonStateChangeDate null
- repos: fix commit author fields null
- upgrade dependencies
- sentry: log errors only if user is logged in

## 1.6.0 - 2023-04-14
- ios: perform xcode suggested actions
- handle deleted projects
- show pipelines/woork items/commits/prs even if some are errors
- member_detail: fix user data null
- pull_requests: fix user directoryAlias null
- work_items: fix url null in get work item detail
- small UI improvements
- pull_requests: make links in description clickable
- work_items: make link in description clickable
- ios: bump minimum supported os version
- sentry: fix user null after first login
- android: fix native splash showing app icon

## 1.5.0 - 2023-03-30
- login: fix PAT info alert and fix test
- allow login with single org token
- improve image error widget in home and avatar
- sentry: avoid loggin api errors in debug mode
- remove empty test file
- fix snackbar text too long
- upgrade dependencies
- test: add choose projects tests
- refactoring: extract method to select org
- test: add login tests

## 1.4.1 - 2023-03-27
- commits: improve diff UI
- fix users not showing on first login
- show error snackbar on unauthorized
- overlay_service: add snackbar method
- fix loading button setState when unmounted
- sentry: increase max breadcrumbs
- work_items: fix edit work item with no project types
- refactoring: move bottomsheets into OverlayService
- rename AlertService -> OverlayService
- sentry: improve logging
- sentry: log session finished only if logged in
- handle network image errors
- project_detail: handle project with no languages
- project_detail: handle project with no team
- work_items: fix type description null
- repo_detail: fix type cast error on api error
- work_items: fix priority null

## 1.4.0 - 2023-03-13
- work_items: fix create
- sentry: log api errors and app session
- settings: share app
- login: add link to PAT docs
- repos: improve text style with readme files
- upgrade dependencies
- work_items: fix work item type not found exception
- fix text overflow with long headers
- rename app page component
- use same page component everywhere
- save projects to local storage sorted by last update
- work_items: check that title is not empty in create and edit
- file_diff: handle binary files
- show scrollbar in some pages
- fix pull to refresh
- upgrade dependencies
- show scrollbar in some pages
- repos: add syntax highlighting in file detail page
- repos: handle markdown files in file detail page
- repos: handle images and binary files in file detail page
- repos: handle empty repo
- repos: switch branch only in root directory
- repos: switch between branches
- repo_detail: remove unused argument
- commits: fix navigation to diff when coming from pipeline detail
- commits: fix wrong author when navigating from pipeline detail
- repos: add repo directory and file navigation
- commits: improve detail page UI
- improve project and repo links UI
- commits: improve file diff UI
- android: improve close app confirm alert

## 1.3.0 - 2023-02-23
- work_items: delete work item
- commits: improve file diff UI
- work_items: change status if necessary in edit work item
- work_items: fix edit work item content type

## 1.2.0 - 2023-02-21
- pipelines: improve detail page UI
- pipelines: add support for logs formatting commands
- commits: show single file diff
- work_items: fix edit work item bottomsheet title
- bump version
- work_items: change work item status
- pipelines: fix trim logs date

## 1.1.0 - 2023-02-20
- pipelines: improve logs UI
- work_items: edit work item
- upgrade dependencies
- add form field component
- code cleaning
- new icon font
- use share_plus instead of share and upgrade packages
- work_items: add work item creation
- pipelines: improve timeline
- login: fix create token link
- pipeline_detail: fix start time null
- improve token expired error alert
- pipeline_detail: improve cancel/rerun alerts
- pipelines: show timeline and logs
- add readme

## 1.0.0
- First release
- Initial commit
