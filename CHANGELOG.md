# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Modified
- decrease amount of css
- convert png icons to webp format
- add compression for webpacker

### Fixed
- bug https://github.com/kortirso/comcon/issues/32
- bug with datepicker css

### Fixed
- creating/updating events

## [1.3.0] - 2020-03-14
### Modified
- rendering subscribers for events
- rendering events

## [1.2.8] - 2020-01-29
### Fixed
- bank updating
- bank deleting

## [1.2.7] - 2020-01-28
### Added
- calculation of item level for characters

### Modified
- alternative renderer is view by default if available
- character's links as a tags

## [1.2.6] - 2020-01-27
### Modified
- group bank cells by bags
- activities page
- removed DungeonAccess model
- character names like links

### Fixed
- deleting empty guilds

## [1.2.5] - 2020-01-16
### Added
- api endpoint v2/activities#index
- declined subscribe status

### Modified
- rendering for guild information
- rendering for static information

### Fixed
- background jobs

## [1.2.4] - 2020-01-10
### Added
- user_token#create api v2 endpoint
- equipment uploading

### Modified
- line up page
- ProfScanner addon
- news can be for everyone

## [1.2.3] - 2020-01-02
### Added
- discord link in footer

### Modified
- styles at statics page
- temp modification activities time

## [1.2.2] - 2019-12-27
### Fixed
- translation
- styles for event calendar
- n+1 for event calendar

## [1.2.1] - 2019-12-26
### Added
- counters
- Onixia's reset

## [1.2.0] - 2019-12-25
### Added
- model Activity
- ActivityDryForm
- Activities page for guilds
- creating activities
- activities page with last guild news
- update/delete activities
- activity's notifications
- remember sign in with email/password
- closest events at activities page
- description at welcome page

### Modified
- translation for privacy policy

## [1.1.9] - 2019-12-24
### Modified
- event calendar with subscribe statuses

## [1.1.8] - 2019-12-21
### Added
- character transfers

### Modified
- delete all static invites after approving one of them

## [1.1.7] - 2019-12-21
### Added
- deleting subscribes for events
- tooltips for navigation icons

### Modified
- for not subscribed characters for event show only active static members

## [1.1.6] - 2019-12-20
### Added
- dry-types, dry-struct, dry-validation for form objects
- fast_jsonapi library for faster serialization
- v2 endpoints
- russian privacy policy

### Modified
- worlds#index and recipes#index endpoints to v2

## [1.1.5] - 2019-12-19
### Added
- locale to guilds
- time_offset to guilds
- repeatable event creation
- translations for notifications

### Fixed
- using left_value for searching statics with character
- bug with not-deleting bank cells
- bug with double subscribe for event

## [1.1.4] - 2019-12-18
### Added
- deleting for bank requests
- filters statics by character main_role

### Modified
- real time indexes

## [1.1.3] - 2019-12-16
### Added
- guild bank users notifications about new bank requests
- filters to bank

### Modofied
- guild tabs navigation

## [1.1.2] - 2019-12-15
### Added
- meta information

### Modified
- load wowhead only for need pages
- aria-label for links without text
- noreferrer for external links
- labels for form elements

## [1.1.1] - 2019-12-14
### Added
- navigation icons
- support in telegram
- request to static at static page
- favicon

### Modified
- delete icon
- close import windows for bank immediately
- show event info better
- footer
- rename operations to actions
- icons

## [1.1.0] - 2019-12-13
### Added
- banker guild role
- guild bank page
- Bank model
- api endpoint for import bank data
- BankCell model
- creating/updating/deleting bank cells from addon data
- GameItem models
- Parser for bank data
- render bank cells
- BankRequest model
- creating bank requests
- render bank requests
- declining for bank requests
- approving for bank requests

## [1.0.1] - 2019-12-11
### Added
- kick character from static

### Modified
- allow for only owner to change subscribe status after closed registration
- for alternative renderer show current amount / need amount

## [1.0.0] - 2019-12-10
### Added
- render static invites for characters
- search for statics
- donate page

### Modified
- clear paladin/shaman roles in group_role values for opposite fraction
- one search statis page for all user characters
- one search guilds page for all user characters
- all views for errors, bugs and n+1

### Fixed
- remove empty guild roles

## [0.9.10] - 2019-12-09
### Modified
- hide paladin/shaman for static/events create/edit forms

### Fixed
- redirect after upload recipes for characters
- make comment in static
- craft bug based on old cache value for guilds
- deleting guild when no members
- bug with creating character without guild invite

## [0.9.9] - 2019-12-07
### Added
- alternative renderer for static members
- leave from static
- count left roles for static
- render left roles for statics

### Modified
- create/update group_roles for statics
- Subscribe model for polymorphic relationships

### Fixed
- puma package version
- serialize-javascript package version

## [0.9.8] - 2019-12-06
### Added
- new error pages
- new icons
- remove guild invite notifications from user that lost gm role (if there are no gm role in any other guild)

### Modified
- generate token after expiration
- redirecting after deleting
- remove capitalize for guild name
- send guild invite notifications if only delivery exists in guild's settings
- create delivery about guild invite only for users that does not have it
- create delivery about guild invite after creating gm role for user if user does not have it

## [0.9.7] - 2019-12-05
### Added
- GM notifications about guild requests from user (send to head users in guild)

### Fixed
- list of characters for guil page

## [0.9.6] - 2019-12-05
### Added
- create guild invite while character creation
- automatic approving guild invites for twinks
- invite form at guild page
- not subscribed for event static members

### Modified
- event page, show hours before close event
- manual typing event start time

## [0.9.5] - 2019-12-04
### Modified
- design

## [0.9.4] - 2019-12-02
### Modified
- character's name limit is 12, guild's name limit is 24 and capitalized
- confirm user after attaching discord account

### Fixed
- disbund guild after self-kick of last character

## [0.9.3] - 2019-12-01
### Modified
- notify structure
- tests

### Fixed
- bug with event edit form
- bug with approving healers

## [0.9.2] - 2019-11-30
### Added
- notification for event_creation_for_guild_static

### Fixed
- bug with static show

## [0.9.1] - 2019-11-30
### Added
- model GroupRole
- creating group roles for events that need in raid
- allow to approve in raid with not only main role
- "In reserve" status
- alternative renderer for event subscribers
- everybody use same change subscribe method

## [0.9.0] - 2019-11-26
### Added
- copy raid to clipboard for fast raid inviting

### Fixed
- bug with scrolling calendar

## [0.8.9] - 2019-11-26
### Modified
- event calendar
- direct link to event subscribes
- change weeks for event calendar

## [0.8.8] - 2019-11-25
### Added
- reset password process
- amount of approved characters for event

### Modified
- responsive navigation
- tests

### Fixed
- fix static management page

## [0.8.7] - 2019-11-24
### Added
- description for guilds
- guild creation form for creating/updating

### Modified
- guilds page
- characters page
- event calendar page
- event page
- craft page
- settings page
- statics page

## [0.8.6] - 2019-11-23
### Added
- model WorldFraction for combination of worlds and fractions
- effect name and effect links for recipes

### Modify
- requests to DB to find available events
- rebuild event calendar for faster filtering
- crafters search will start after recipe select
- change subscribe translations for line up component

### Fix
- N+1 problems

## [0.8.5] - 2019-11-21
### Added
- mail settings with SendGrid
- sending confirmation email
- confirmation page

### Fixed
- bug with static name at static edit form

## [0.8.4] - 2019-11-20
### Added
- new dns name - https://guild-hall.org

### Modified
- url in notifications

### Fixed
- bug with approving to static event of guild by Class Leader
- bug with updating subscribe by Class Leader
- bug with auth with discord
- last fixes for discord oauth

## [0.8.3] - 2019-11-18
### Fixed
- bug with static show for simple static members

## [0.8.2] - 2019-11-17
### Added
- creating of private/public statics
- render list of public statics at statics page
- character page with recipes

### Modified
- allow to RL and CL of guild approve characters in guild statics

## [0.8.1] - 2019-11-17
### Fixed
- bug with event creation for statics

## [0.8.0] - 2019-11-15
### Modified
- days rendering at event calendar
- rendering of guild members
- error alerts for static form
- delete static invite after approving

### Fixed
- bug with delivery creation for guilds
- bug with invite guild co-members to static
- bug with not current month in event calendar

## [0.7.8] - 2019-11-14
### Added
- beautiful icons

## [0.7.7] - 2019-11-14
### Added
- change password for users
- error alerts for delivery form
- success alert for user settings

### Modified
- tests for user notifications
- sort static members by role, class_name, level and name

## [0.7.6] - 2019-11-13
### Added
- settings page for external services
- settings page for notifications
- create notifications for users
- send notifications for users

### Fixed
- datetimepicker at event calendar

## [0.7.5] - 2019-11-13
### Added
- settings page
- TimeOffset model for user preferences about rendered time
- selecting prefered time for users
- render all times for user time zone

## [0.7.4] - 2019-11-12
### Added
- api endpoint recipes#search
- search recipes for crafters

## [0.7.3] - 2019-11-11
### Fixed
- bug with line up

## [0.7.2] - 2019-11-11
### Added
- rescue from ActionView::MissingTemplate errors

### Modified
- rebuild event form for subscribers
- ProfScanner addon

### Fixed
- remove guild invites from guilds page
- bug with time selector for event editing

## [0.7.1] - 2019-11-08
### Added
- characters recipes uploader
- Addon from Ardash for getting list of addons
- event calendar filter to see only subscribed events

### Modified
- render identities of users at users page

## [0.7.0] - 2019-11-08
### Added
- omniauth support
- login through discord
- save user in session for discord auth
- linking other network's accounts with existed account

### Fixed
- security vulnerability

## [0.6.7] - 2019-11-08
### Fixed
- bug with character updating and lefting guild
- bug with event form calendar

## [0.6.6] - 2019-11-07
### Added
- guild search indexes
- beautiful datetime picker

### Modified
- guild invite page with react components

## [0.6.5] - 2019-11-07
### Added
- left guild by characters
- generate new gm or disbund the guild
- GuildInvite model
- page for guild invites
- api endpoint for creating guild invites
- deleting guild invites
- approving/declining guild invites by users

### Modified
- removed guild selection from character form

## [0.6.4] - 2019-11-06
### Added
- ErrorView react component for rendering errors in forms
- API localization with locale param
- kick from guild

### Modified
- events name cutting at event calendar
- event page
- discord bot message about new guild event

## [0.6.3] - 2019-11-06
### Added
- discord_bot library
- Notification model
- Delivery model
- DeliveryParam model
- creating delivery with param
- sending notifications through discord webhooks

## [0.6.2] - 2019-11-04
### Added
- events deleting
- static members deleting
- creating static events

### Modified
- tests

## [0.6.1] - 2019-11-04
### Added
- static show page
- static management page
- StaticMember model
- creating static member for new characters statics
- rendering statics for user with membership
- rendering members of statics
- search engine
- api endpoint characters#search
- rendering search results
- StaticInvite model
- creating invites to statics
- approving and declining for static invites

### Modified
- styles and translations

### Fix
- 24 hours time presentation for events calendar

## [0.6.0] - 2019-11-01
### Added
- model Static
- new and create endpoints for statics (for characters and for guilds)
- edit, update and destroy endpoints for statics

### Fixed
- bug with opening events without user
- bug with searching crafters with fraction_id param

## [0.5.4] - 2019-10-31
### Fixed
- bug with guild duplicates in event calendar

## [0.5.3] - 2019-10-31
## Added
- show selected event at calendar
- show selected day at calendar
- edit mode for event_form

### Modified
- event form with react component
- time presentation in local time zone for events page
- name length limit for event
- show only 4 first events in event calendar's day

### Fixed
- bug with events for not current month

## [0.5.2] - 2019-10-30
### Added
- recipes cacher
- endpoints fore searching crafters

### Fixed
- redirect bug after recipe deleting

## [0.5.1] - 2019-10-30
### Added
- limit for characters name
- recipe uploader from csv
- dungeon seeds

### Fixed
- bug at lineup page with approving

## [0.5.0] - 2019-10-28
### Added
- allow approving to radi for raid leaders and class leaders
- guild page
- guild roles

## [0.4.3] - 2019-10-25
### Added
- guilds page

## [0.4.2] - 2019-10-24
### Added
- characters can select recipes they know

## [0.4.1] - 2019-10-24
### Added
- recipes

## [0.4.0] - 2019-10-24
### Added
- characters can select professions they know
- counters for raid lineup

## [0.3.3] - 2019-10-22
### Added
- stop registration time for events
- auto subscribe for event's creator

### Modified
- hide calendar for no characters users

### Fixed
- character form's secondary roles

## [0.3.2] - 2019-10-20
### Description
- Start web server

### Added
- cache mechanizm for api
- combinations for race/character_class/role
- deploy config
- localization
- event's calendar with event page

### Modified
- character form with react
- project name to ComCon

### Fixed
- character form's secondary roles
