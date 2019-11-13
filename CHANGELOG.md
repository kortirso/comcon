# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- settings page for external services

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
