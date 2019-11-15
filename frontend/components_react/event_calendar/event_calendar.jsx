import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

export default class EventCalendar extends React.Component {
  constructor(props) {
    super(props)
    const date = new Date()
    this.state = {
      events: [],
      previousDaysAmount: (new Date(date.getFullYear(), date.getMonth(), 1)).getDay() - 1,
      daysAmount: (new Date(date.getFullYear(), date.getMonth() + 1, 0)).getDate(),
      currentYear: date.getFullYear(),
      currentMonth: date.getMonth() + 1,
      currentDay: date.getDate(),
      timeZoneOffsetMinutes: props.time_offset_value === null ? date.getTimezoneOffset() : - props.time_offset_value * 60,
      monthChanges: 0,
      worlds: [],
      guilds: [],
      fractions: [],
      dungeons: [],
      alliance: 0,
      horde: 0,
      characters: [],
      accessType: 'none',
      world: 'none',
      guild: 'none',
      fraction: 'none',
      character: 'none',
      subscribe: 'none',
      currentEventId: null,
      currentDayId: null
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getFilterValues()
  }

  componentDidMount() {
    this._getEvents()
  }

  _getEvents() {
    const state = this.state
    let params = []
    if (state.accessType !== 'none') params.push(`eventable_type=${state.accessType}`)
    if (state.world !== 'none') params.push(`eventable_id=${state.world}`)
    if (state.guild !== 'none') params.push(`eventable_id=${state.guild}`)
    if (state.fraction !== 'none') params.push(`fraction_id=${state.fraction}`)
    if (state.character !== 'none') params.push(`character_id=${state.character}`)
    if (state.subscribe === 'all') params.push(`subscribed=true`)
    params.push(`month=${state.currentMonth}`)
    params.push(`year=${state.currentYear}`)
    const url = `/api/v1/events.json?access_token=${this.props.access_token}&` + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({events: data.events})
      }
    })
  }

  _getFilterValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/filter_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        let alliance
        let horde
        data.fractions.forEach((fraction) => {
          if (fraction.name.en === 'Horde') horde = fraction.id
          else alliance = fraction.id
        })
        this.setState({worlds: data.worlds, fractions: data.fractions, alliance: alliance, horde: horde, guilds: data.guilds, characters: data.characters, dungeons: data.dungeons})
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

  _renderPreviousMonth(value) {
    let days = []
    let amount = this.state.previousDaysAmount
    if (value === 'next') amount = 7 - (this.state.previousDaysAmount + this.state.daysAmount) % 7
    for (let i = 0; i < amount; i++) {
      days.push(
        <div className="day previous" key={i}>
          <div className="day_content"></div>
        </div>
      )
    }
    return days
  }

  _renderMonthDays() {
    let days = []
    for (let i = 0; i < this.state.daysAmount; i++) {
      days.push(
        <div className={this._defineDayClass(i + 1)} key={i}>
          <div className="day_content" onClick={this._onSelectCurrentDay.bind(this, i + 1)}>
            <div className="day_date">{i + 1}.{this.state.currentMonth}</div>
            {this._renderEvents(i + 1)}
          </div>
        </div>
      )
    }
    return days
  }

  _defineDayClass(value) {
    let result = ["day"]
    if (this.state.monthChanges < 0 || this.state.monthChanges === 0 && value < this.state.currentDay) result.push('finished')
    if (this.state.currentDayId !== null && parseInt(this.state.currentDayId.split(".")[0]) === value) result.push('selected')
    return result.join(" ")
  }

  _renderEvents(day) {
    const filtered = this.state.events.filter((event) => {
      return event.date == `${day}.${this.state.currentMonth}.${this.state.currentYear}`
    })
    if (filtered.length <= 4) {
      return filtered.map((event) => {
        return this._renderEventString(event)
      })
    } else {
      let result = []
      filtered.slice(0, 4).map((event) => {
        result.push(this._renderEventString(event))
      })
      result.push(
        <a className='others' key={0}>
          <p>{strings.otherEvents}</p>
        </a>
      )
      return result
    }
  }

  _renderEventString(event) {
    let days = '0'
    let hours = event.time.hours - this.state.timeZoneOffsetMinutes / 60
    if (hours < 0) {
      hours += 24
      days = '-1'
    } else if (hours > 23) {
      hours -= 24
      days = '+1'
    }
    const minutes = event.time.minutes
    const eventTime = (hours < 10 ? `0${hours}` : `${hours}`) + ':' + (minutes < 10 ? `0${minutes}` : `${minutes}`) + this._renderOtherDays(days)
    return (
      <a className={this._eventFractionClass(event.fraction_id)} key={event.id} onClick={() => this.setState({currentEventId: event.id})}>
        <p className="name">{eventTime} - {event.name}</p>
      </a>
    )
  }

  _renderOtherDays(value) {
    if (value === '0') return ''
    else return `(${value})`
  }

  _onSelectCurrentDay(value) {
    this.setState({currentDayId: `${value}.${this.state.currentMonth}.${this.state.currentYear}`})
  }

  _eventFractionClass(fractionId) {
    if (fractionId === this.state.alliance) return "event alliance"
    else return "event horde"
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderAccessTypeFilter()}
        {this._renderWorldFilter()}
        {this._renderGuildFilter()}
        {this._renderFractionFilter()}
        {this._renderCharacterFilter()}
        {this._renderSubscribeFilter()}
      </div>
    )
  }

  _renderAccessTypeFilter() {
    return (
      <div className="filter access_type">
        <p>{strings.filterAccess}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeAccessType.bind(this)} value={this.state.accessType}>
          <option value='none'>{strings.none}</option>
          <option value='World'>{strings.onlyWorlds}</option>
          <option value='Guild'>{strings.onlyGuilds}</option>
        </select>
      </div>
    )
  }

  _renderWorldFilter() {
    if (this.state.accessType !== 'World') return false
    else {
      return (
        <div className="filter world">
          <p>{strings.filterWorld}</p>
          <select className="form-control form-control-sm" onChange={this._onChangeWorld.bind(this)} value={this.state.world}>
            <option value='none' key='0'>{strings.none}</option>
            {this._renderWorldsList()}
          </select>
        </div>
      )
    }
  }

  _renderWorldsList() {
    return this.state.worlds.map((world) => {
      return <option value={world.id} key={world.id}>{world.name}</option>
    })
  }

  _renderGuildFilter() {
    if (this.state.accessType !== 'Guild') return false
    else {
      return (
        <div className="filter guild">
          <p>{strings.filterGuild}</p>
          <select className="form-control form-control-sm" onChange={this._onChangeGuild.bind(this)} value={this.state.guild}>
            <option value='none' key='0'>{strings.none}</option>
            {this._renderGuildsList()}
          </select>
        </div>
      )
    }
  }

  _renderGuildsList() {
    return this.state.guilds.map((guild) => {
      return <option value={guild.id} key={guild.id}>{guild.full_name}</option>
    })
  }

  _renderFractionFilter() {
    if (this.state.guild !== 'none') return false
    else {
      return (
        <div className="filter fraction">
          <p>{strings.filterFraction}</p>
          <select className="form-control form-control-sm" onChange={this._onChangeFraction.bind(this)} value={this.state.fraction}>
            <option value='none' key='0'>{strings.none}</option>
            {this._renderFractionsList()}
          </select>
        </div>
      )
    }
  }

  _renderFractionsList() {
    return this.state.fractions.map((fraction) => {
      return <option value={fraction.id} key={fraction.id}>{fraction.name[this.props.locale]}</option>
    })
  }

  _renderCharacterFilter() {
    return (
      <div className="filter character">
        <p>{strings.filterCharacter}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeCharacter.bind(this)} value={this.state.character}>
          <option value='none' key='0'>{strings.none}</option>
          {this._renderCharactersList()}
        </select>
      </div>
    )
  }

  _renderCharactersList() {
    return this.state.characters.map((character) => {
      return <option value={character.id} key={character.id}>{character.name}</option>
    })
  }

  _renderSubscribeFilter() {
    return (
      <div className="filter subscribe">
        <p>{strings.filterSubscribe}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeSubscribe.bind(this)} value={this.state.subscribe}>
          <option value='none' key='0'>{strings.none}</option>
          <option value='all' key='1'>{strings.withSubscription}</option>
        </select>
      </div>
    )
  }

  _onChangeAccessType(event) {
    if (event.target.value === 'none') {
      this.setState({accessType: 'none', world: 'none', guild: 'none', currentEventId: null}, () => {
        this._getEvents()
      })
    } else {
      this.setState({accessType: event.target.value, world: 'none', guild: 'none', currentEventId: null}, () => {
        this._getEvents()
      })
    }
  }

  _onChangeWorld(event) {
    this.setState({world: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._getEvents()
    })
  }

  _onChangeGuild(event) {
    this.setState({guild: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._getEvents()
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._getEvents()
    })
  }

  _onChangeCharacter(event) {
    this.setState({character: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._getEvents()
    })
  }

  _onChangeSubscribe(event) {
    this.setState({subscribe: event.target.value, currentEventId: null, currentDayId: null}, () => {
      this._getEvents()
    })
  }

  _onChangeMonth(value) {
    let currentYear = this.state.currentYear
    let previousYear = this.state.currentYear
    let currentMonth = this.state.currentMonth
    let previousMonth = this.state.currentMonth - 1
    if (value === -1 && currentMonth === 1) {
      currentYear -= 1
      previousYear -= 1
      currentMonth = 12
      previousMonth = 11
    } else if (value === 1 && currentMonth === 12) {
      currentYear += 1
      currentMonth = 1
      previousMonth = 12
    } else {
      currentMonth += value
      previousMonth += value
    }

    let previous = (new Date(previousYear, previousMonth, 1)).getDay() - 1
    if (previous < 0) previous += 7
    this.setState({
      monthChanges: this.state.monthChanges + value,
      previousDaysAmount: previous,
      daysAmount: (new Date(currentYear, currentMonth, 0)).getDate(),
      currentYear: currentYear,
      currentMonth: currentMonth,
      currentEventId: null,
      currentDayId: null
    }, () => {
      this._getEvents()
    })
  }

  _renderCurrentDay() {
    if (this.state.currentDayId === null) return <p>{strings.noDay}</p>
    else {
      const filtered = this.state.events.filter((event) => {
        return event.date == this.state.currentDayId
      })
      const events = filtered.map((event) => {
        return this._renderEventString(event)
      })
      return (
        <div className="current-day-data">
          <p className="current-date">{this.state.currentDayId}</p>
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
      let hours = currentEvent.time.hours - this.state.timeZoneOffsetMinutes / 60
      if (hours < 0) {
        hours += 24
        days = '-1'
      } else if (hours > 23) {
        hours -= 24
        days = '+1'
      }
      const minutes = currentEvent.time.minutes
      return (
        <div className="current-event-data">
          <p className={'name ' + this._eventFractionClass(currentEvent.fraction_id)}>{currentEvent.name}</p>
          {currentDungeon.length !== 0 &&
            <p>{strings.place} - {currentDungeon[0].name[this.props.locale]}</p>
          }
          <p>{strings.startTime} - {currentEvent.date} {strings.at} {hours < 10 ? `0${hours}` : hours}:{minutes < 10 ? `0${minutes}` : minutes}{this._renderOtherDays(days)}</p>
          {currentEvent.description !== '' &&
            <p>{currentEvent.description}</p>
          }
          <div className="buttons">
            <a className="btn btn-primary btn-sm with_right_margin" href={`${this.props.locale === 'en' ? '' : '/' + this.props.locale}/events/${currentEvent.slug}`}>{strings.subscribed}</a>
            {this.props.user_character_ids.includes(currentEvent.owner_id) &&
              <a className="btn btn-primary btn-sm with_right_margin" href={`${this.props.locale === 'en' ? '' : '/' + this.props.locale}/events/${currentEvent.slug}/edit`}>{strings.edit}</a>
            }
            {this.props.user_character_ids.includes(currentEvent.owner_id) &&
              <button data-confirm={strings.sure} className="btn btn-primary btn-sm" onClick={this._onDeleteEvent.bind(this, currentEvent)}>{strings.deleteButton}</button>
            }
          </div>
        </div>
      )
    }
  }

  render() {
    return (
      <div className="events">
        <div className="container">
          {this._renderFilters()}
          <div className="calendar_arrows">
            <button className="btn btn-primary btn-sm with_right_margin" onClick={this._onChangeMonth.bind(this, -1)}>{strings.previous}</button>
            <button className="btn btn-primary btn-sm" onClick={this._onChangeMonth.bind(this, 1)}>{strings.next}</button>
          </div>
        </div>
        <div className="calendar-block">
          <div className="calendar">
            {this._renderPreviousMonth('previous')}
            {this._renderMonthDays()}
            {this._renderPreviousMonth('next')}
          </div>
          <div className="current-data">
            <div className="current-day">
              <p>{strings.selectedDay}</p>
              {this._renderCurrentDay()}
            </div>
            <div className="current-event">
              <p>{strings.selectedEvent}</p>
              {this._renderCurrentEvent()}
            </div>
          </div>
        </div>
      </div>
    )
  }
}
