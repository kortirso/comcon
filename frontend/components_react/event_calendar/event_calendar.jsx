import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

export default class EventCalendar extends React.Component {
  constructor(props) {
    super(props)
    let date = new Date()
    const currentDay = date.getDay() === 0 ? 7 : date.getDay()
    date.setDate(date.getDate() - 7 - (currentDay - 1))
    this.state = {
      events: [],
      filteredEvents: [],
      currentYear: date.getFullYear(),
      currentMonth: date.getMonth(),
      currentDate: date.getDate(),
      currentDay: currentDay,
      timeZoneOffsetMinutes: props.time_offset_value === null ? date.getTimezoneOffset() : - props.time_offset_value * 60,
      weekChanges: 0,
      currentDayId: null,
      guilds: [],
      statics: [],
      fractions: [],
      dungeons: [],
      alliance: 0,
      horde: 0,
      characters: [],
      accessType: 'none',
      guild: 'none',
      currentStatic: 'none',
      fraction: 'none',
      dungeon: 'none',
      character: 'none',
      currentEventId: null,
      calendarStartForOnixia: this._calcStartValue(date),
      showUnusualCD: false,
      raidForUS: false
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getFilterValues()
  }

  componentDidMount() {
    this._getEvents()
  }

  _calcStartValue(date) {
    const onixiaStart = new Date(2020, 0, 4, 0, 0, 0, 0)
    return parseInt((date.getTime() - onixiaStart.getTime()) / (1000 * 3600 * 24))
  }

  _getEvents() {
    const state = this.state
    let params = []
    if (state.character !== 'none') params.push(`character_id=${state.character}`)
    const selectedDate = new Date(state.currentYear, state.currentMonth, state.currentDate + state.weekChanges * 7, 0, 0, 0)
    params.push(`month=${selectedDate.getMonth() + 1}`)
    params.push(`year=${selectedDate.getFullYear()}`)
    params.push(`day=${selectedDate.getDate()}`)
    params.push(`days=28`)
    const url = `/api/v2/events.json?access_token=${this.props.access_token}&` + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({events: data.events.data}, () => {
          this._filterEvents()
        })
      }
    })
  }

  _filterEvents() {
    const state = this.state
    let filters = {}
    if (state.accessType !== 'none') filters['eventable_type'] = state.accessType
    if (state.guild !== 'none') filters['eventable_id'] = state.guild
    if (state.currentStatic !== 'none') filters['eventable_id'] = state.currentStatic
    if (state.fraction !== 'none') filters['fraction_id'] = state.fraction
    if (state.dungeon !== 'none') filters['dungeon_id'] = state.dungeon
    const events = state.events.filter(function(event) {
      for (var key in filters) {
        if (event.attributes[key] === undefined || event.attributes[key] != filters[key]) return false
      }
      return true
    })
    this.setState({filteredEvents: events})
  }

  _getFilterValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v2/events/filter_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        let alliance
        let horde
        data.fractions.data.forEach((fraction) => {
          if (fraction.attributes.name.en === 'Horde') horde = parseInt(fraction.id)
          else alliance = parseInt(fraction.id)
        })
        this.setState({fractions: data.fractions.data, alliance: alliance, horde: horde, guilds: data.guilds.data, characters: data.characters.data, dungeons: data.dungeons.data, statics: data.statics.data})
      }
    })
  }

  _onDeleteEvent(event) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/events/${event.id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const events = [... this.state.events]
        const eventIndex = events.indexOf(event)
        events.splice(eventIndex, 1)
        this.setState({events: events, currentEventId: null})
      }
    })
  }

  _renderDays() {
    const state = this.state
    let days = []
    for (let i = 0; i < 28; i++) {
      const dateForDay = new Date(state.currentYear, state.currentMonth, state.currentDate + i + state.weekChanges * 7, 0, 0, 0)
      days.push(
        <div className={this._defineDayClass(i + 1)} key={i}>
          <div className="day_content" onClick={this._onSelectCurrentDay.bind(this, i)}>
            <div className="day_date">{dateForDay.getDate()}.{dateForDay.getMonth() + 1}</div>
            {this.state.showUnusualCD &&
              <div className={`onixia_line ${this._defineOnixiaDay(i)}`}></div>
            }
            {this._renderEvents(dateForDay)}
          </div>
        </div>
      )
    }
    return days
  }

  _defineOnixiaDay(i) {
    switch ((this.state.calendarStartForOnixia + this.state.weekChanges * 7 + i + (this.state.raidForUS ? -1 : 0)) % 5) {
      case 0:
        return 'onixia_start'
        break;
      case -1:
        return 'onixia_end'
        break;
      case 4:
        return 'onixia_end'
        break;
      default:
        return ''
    }
  }

  _onSelectCurrentDay(value) {
    this.setState({currentDayId: value})
  }

  _renderEvents(dateForDay) {
    const filtered = this.state.filteredEvents.filter((event) => {
      return event.attributes.date == `${dateForDay.getDate()}.${dateForDay.getMonth() + 1}.${dateForDay.getFullYear()}`
    })
    if (filtered.length <= 5) {
      return filtered.map((event) => {
        return this._renderEventString(event, true)
      })
    } else {
      let result = []
      filtered.slice(0, 5).map((event) => {
        result.push(this._renderEventString(event, true))
      })
      result.push(
        <a className='others' key={0}>
          <p>{strings.otherEvents}</p>
        </a>
      )
      return result
    }
  }

  _defineDayClass(value) {
    let result = ["day"]
    if (value < 7 + this.state.currentDay - this.state.weekChanges * 7) result.push('finished')
    if (this.state.currentDayId === value - 1) result.push('selected')
    return result.join(" ")
  }

  _renderEventString(event, withClick) {
    let days = '0'
    let hours = event.attributes.time.hours - this.state.timeZoneOffsetMinutes / 60
    if (hours < 0) {
      hours += 24
      days = '-1'
    } else if (hours > 23) {
      hours -= 24
      days = '+1'
    }
    const minutes = event.attributes.time.minutes
    const eventTime = (hours < 10 ? `0${hours}` : `${hours}`) + ':' + (minutes < 10 ? `0${minutes}` : `${minutes}`) + this._renderOtherDays(days)
    return (
      <a className={this._eventFractionClass(event.attributes.fraction_id)} key={event.id} onClick={this._onSelectEvent.bind(this, event, withClick)}>
        <p className="name">{eventTime} - {event.attributes.name}</p>
        <span className={`status_icon extra_small ${event.attributes.status}`}></span>
      </a>
    )
  }

  _renderOtherDays(value) {
    if (value === '0') return ''
    else return `(${value})`
  }

  _eventFractionClass(fractionId) {
    if (fractionId === this.state.alliance) return "event alliance"
    else return "event horde"
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderAccessTypeFilter()}
        {this._renderGuildFilter()}
        {this._renderStaticFilter()}
        {this._renderFractionFilter()}
        {this._renderDungeonFilter()}
        {this._renderCharacterFilter()}
      </div>
    )
  }

  _renderAccessTypeFilter() {
    return (
      <div className="filter access_type">
        <label htmlFor="filter_access_type">{strings.filterAccess}</label>
        <select id="filter_access_type" className="form-control form-control-sm" onChange={this._onChangeAccessType.bind(this)} value={this.state.accessType}>
          <option value='none'>{strings.none}</option>
          <option value='Guild'>{strings.onlyGuilds}</option>
          <option value='Static'>{strings.onlyStatics}</option>
        </select>
      </div>
    )
  }

  _renderGuildFilter() {
    if (this.state.accessType !== 'Guild') return false
    else {
      return (
        <div className="filter guild">
          <label htmlFor="filter_guild">{strings.filterGuild}</label>
          <select id="filter_guild" className="form-control form-control-sm" onChange={this._onChangeGuild.bind(this)} value={this.state.guild}>
            <option value='none' key='0'>{strings.none}</option>
            {this._renderGuildsList()}
          </select>
        </div>
      )
    }
  }

  _renderGuildsList() {
    return this.state.guilds.map((guild) => {
      return <option value={guild.id} key={guild.id}>{guild.attributes.full_name}</option>
    })
  }

  _renderStaticFilter() {
    if (this.state.accessType !== 'Static') return false
    else {
      return (
        <div className="filter static">
          <label htmlFor="filter_static">{strings.filterStatic}</label>
          <select id="filter_static" className="form-control form-control-sm" onChange={this._onChangeStatic.bind(this)} value={this.state.currentStatic}>
            <option value='none' key='0'>{strings.none}</option>
            {this._renderStaticsList()}
          </select>
        </div>
      )
    }
  }

  _renderStaticsList() {
    return this.state.statics.map((currentStatic) => {
      return <option value={currentStatic.id} key={currentStatic.id}>{currentStatic.attributes.name}</option>
    })
  }

  _renderFractionFilter() {
    if (this.state.guild !== 'none') return false
    else {
      return (
        <div className="filter fraction">
          <label htmlFor="filter_fraction">{strings.filterFraction}</label>
          <select id="filter_fraction" className="form-control form-control-sm" onChange={this._onChangeFraction.bind(this)} value={this.state.fraction}>
            <option value='none' key='0'>{strings.none}</option>
            {this._renderFractionsList()}
          </select>
        </div>
      )
    }
  }

  _renderFractionsList() {
    return this.state.fractions.map((fraction) => {
      return <option value={fraction.id} key={fraction.id}>{fraction.attributes.name[this.props.locale]}</option>
    })
  }

  _renderDungeonFilter() {
    return (
      <div className="filter dungeon">
        <label htmlFor="filter_dungeon">{strings.filterDungeon}</label>
        <select id="filter_dungeon" className="form-control form-control-sm" onChange={this._onChangeDungeon.bind(this)} value={this.state.dungeon}>
          <option value='none' key='0'>{strings.none}</option>
          {this._renderDungeonsList()}
        </select>
      </div>
    )
  }

  _renderDungeonsList() {
    return this.state.dungeons.map((dungeon) => {
      return <option value={dungeon.id} key={dungeon.id}>{dungeon.attributes.name[this.props.locale]}</option>
    })
  }

  _renderCharacterFilter() {
    return (
      <div className="filter character">
        <label htmlFor="filter_character">{strings.filterCharacter}</label>
        <select id="filter_character" className="form-control form-control-sm" onChange={this._onChangeCharacter.bind(this)} value={this.state.character}>
          <option value='none' key='0'>{strings.none}</option>
          {this._renderCharactersList()}
        </select>
      </div>
    )
  }

  _renderCharactersList() {
    return this.state.characters.map((character) => {
      return <option value={character.id} key={character.id}>{character.attributes.name}</option>
    })
  }

  _onChangeAccessType(event) {
    if (event.target.value === 'none') {
      this.setState({accessType: 'none', guild: 'none', currentStatic: 'none', currentEventId: null}, () => {
        this._filterEvents()
      })
    } else {
      this.setState({accessType: event.target.value, guild: 'none', currentStatic: 'none', currentEventId: null}, () => {
        this._filterEvents()
      })
    }
  }

  _onChangeGuild(event) {
    this.setState({guild: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._filterEvents()
    })
  }

  _onChangeStatic(event) {
    this.setState({currentStatic: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._filterEvents()
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._filterEvents()
    })
  }

  _onChangeDungeon(event) {
    this.setState({dungeon: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._filterEvents()
    })
  }

  _onChangeCharacter(event) {
    this.setState({character: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._getEvents()
    })
  }

  _onChangeWeek(value) {
    this.setState({weekChanges: this.state.weekChanges + value}, () => {
      this._getEvents()
    })
  }

  _renderCurrentDay() {
    const state = this.state
    if (this.state.currentDayId === null) return <p>{strings.noDay}</p>
    else {
      const selectedDate = new Date(state.currentYear, state.currentMonth, state.currentDate + state.currentDayId + state.weekChanges * 7, 0, 0, 0)
      const currentDayString = `${selectedDate.getDate()}.${selectedDate.getMonth() + 1}.${selectedDate.getFullYear()}`
      const filtered = this.state.events.filter((event) => {
        return event.attributes.date === currentDayString
      })
      const events = filtered.map((event) => {
        return this._renderEventString(event, false)
      })
      return (
        <div className="current-day-data">
          <p className="current-date">{currentDayString}</p>
          {this._renderDayEvents(events)}
        </div>
      )
    }
  }

  _renderDayEvents(events) {
    if (events.length === 0) return <p>{strings.noDayEvents}</p>
    return events
  }

  _renderCurrentEvent() {
    if (this.state.currentEventId === null) return <p>{strings.noEvents}</p>
    else {
      const currentEvent = this.state.events.filter((event) => {
        return event.id === this.state.currentEventId
      })[0]
      const currentDungeon = this.state.dungeons.filter((dungeon) => {
        return dungeon.id === currentEvent.dungeon_id
      })
      let days = '0'
      let hours = currentEvent.attributes.time.hours - this.state.timeZoneOffsetMinutes / 60
      if (hours < 0) {
        hours += 24
        days = '-1'
      } else if (hours > 23) {
        hours -= 24
        days = '+1'
      }
      const minutes = currentEvent.attributes.time.minutes
      return (
        <div className="current-event-data">
          <p className={'name ' + this._eventFractionClass(currentEvent.attributes.fraction_id)}>{currentEvent.attributes.name}</p>
          {currentDungeon.length !== 0 &&
            <p>{strings.place} - {currentDungeon[0].name[this.props.locale]}</p>
          }
          <p>{strings.startTime} - {currentEvent.attributes.date} {strings.at} {hours < 10 ? `0${hours}` : hours}:{minutes < 10 ? `0${minutes}` : minutes}{this._renderOtherDays(days)}</p>
          {currentEvent.attributes.description !== '' &&
            <p>{currentEvent.attributes.description}</p>
          }
          <div className="buttons">
            <a className="btn btn-primary btn-sm with_right_margin" href={`${this.props.locale === 'en' ? '' : '/' + this.props.locale}/events/${currentEvent.attributes.slug}`}>{strings.subscribed}</a>
            {this.props.user_character_ids.includes(currentEvent.attributes.owner_id) &&
              <a className="btn btn-icon btn-edit with_right_margin" href={`${this.props.locale === 'en' ? '' : '/' + this.props.locale}/events/${currentEvent.attributes.slug}/edit`} aria-label="Edit button"></a>
            }
            {this.props.user_character_ids.includes(currentEvent.attributes.owner_id) &&
              <button data-confirm={strings.sure} className="btn btn-icon btn-delete" onClick={this._onDeleteEvent.bind(this, currentEvent)} aria-label="Delete button"></button>
            }
          </div>
        </div>
      )
    }
  }

  _onSelectEvent(event, withClick, e) {
    if (withClick) {
      e.stopPropagation()
      window.location.href = `${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/events/${event.attributes.slug}`
    } else {
      this.setState({currentEventId: event.id})
    }
  }

  _onChangeRaidCD(event) {
    const raidCD = event.target.value
    if (raidCD === '0') this.setState({raidCD: '0', showUnusualCD: false, raidForUS: false})
    else if (raidCD === '1') this.setState({raidCD: '1', showUnusualCD: true, raidForUS: false})
    else this.setState({raidCD: '2', showUnusualCD: true, raidForUS: true})
  }

  _renderModal() {
    return (
      <div className={`modal fade ${this.state.currentDayId === null ? '' : 'show'}`} id="selectedDayModal" tabIndex="-1" role="dialog" aria-labelledby="selectedDayModalLabel" aria-hidden="true" onClick={() => this._onSelectCurrentDay(null)}>
        <div className="modal-dialog" role="document" onClick={(e) => { e.stopPropagation() }}>
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="selectedDayModalLabel">{strings.eventOfTheDay}</h5>
              <button type="button" className="close" onClick={() => this._onSelectCurrentDay(null)}>
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div className="modal-body">
              <div className="current-data">
                <div className="current-day">
                  {this._renderCurrentDay()}
                </div>
                <div className="current-event">
                  {this._renderCurrentEvent()}
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-primary btn-sm" onClick={() => this._onSelectCurrentDay(null)}>{strings.close}</button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  render() {
    return (
      <div className="events">
        {this._renderFilters()}
        <div className="calendar-block">
          <div className="full-calendar">
            <div className="buttons">
              <div className="cd_buttons">
                <label htmlFor="cd_button">{strings.labelCD}</label>
                <select id="cd_button" className="form-control form-control-sm" onChange={this._onChangeRaidCD.bind(this)} value={this.state.raidCD}>
                  <option value='0'>{strings.nothing}</option>
                  <option value='1'>{strings.forEU}</option>
                  <option value='2'>{strings.forUS}</option>
                </select>
              </div>
              <div className="week_buttons">
                <button className="btn btn-primary btn-sm" onClick={this._onChangeWeek.bind(this, -1)}>{strings.previous}</button>
                <button className="btn btn-primary btn-sm" onClick={this._onChangeWeek.bind(this, 1)}>{strings.next}</button>
              </div>
            </div>
            <div className="calendar">
              {this._renderDays()}
            </div>
          </div>
          {this._renderModal()}
        </div>
      </div>
    )
  }
}
