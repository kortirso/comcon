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
      worlds: [],
      guilds: [],
      fractions: [],
      characters: [],
      accessType: 'none',
      world: 'none',
      guild: 'none',
      fraction: 'none',
      character: 'none'
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getEvents()
  }

  componentDidMount() {
    this._getFilterValues()
  }

  _getEvents() {
    let params = []
    if (this.state.accessType !== 'none') params.push(`eventable_type=${this.state.accessType}`)
    if (this.state.world !== 'none') params.push(`eventable_id=${this.state.world}`)
    if (this.state.guild !== 'none') params.push(`eventable_id=${this.state.guild}`)
    if (this.state.fraction !== 'none') params.push(`fraction_id=${this.state.fraction}`)
    if (this.state.character !== 'none') params.push(`character_id=${this.state.character}`)
    params.push(`month=${this.state.currentMonth}`)
    params.push(`year=${this.state.currentYear}`)
    const url = '/events.json?' + params.join('&')
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
      url: '/events/filter_values.json',
      success: (data) => {
        this.setState({worlds: data.worlds, fractions: data.fractions, guilds: data.guilds, characters: data.characters})
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
        <div className="day" key={i}>
          <div className="day_content">
            <div className="day_date">{i + 1}.{this.state.currentMonth}</div>
            {this._renderEvents(i + 1)}
          </div>
        </div>
      )
    }
    return days
  }

  _renderEvents(day) {
    const filtered = this.state.events.filter((event) => {
      return event.date == `${day}.${this.state.currentMonth}.${this.state.currentYear}`
    })
    return filtered.map((event) => {
      return (
        <a className="event" key={event.id} href={`${this.props.locale === 'en' ? '' : '/' + this.props.locale}/events/${event.slug}`}>
          <p className="name">{event.name}</p>
          <p className="time">{event.time}</p>
        </a>
      )
    })
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderAccessTypeFilter()}
        {this._renderWorldFilter()}
        {this._renderGuildFilter()}
        {this._renderFractionFilter()}
        {this._renderCharacterFilter()}
      </div>
    )
  }

  _renderAccessTypeFilter() {
    return (
      <div className="filter access_type">
        <p>{strings.filterAccess}</p>
        <select className="form-control" onChange={this._onChangeAccessType.bind(this)} value={this.state.accessType}>
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
          <select className="form-control" onChange={this._onChangeWorld.bind(this)} value={this.state.world}>
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
          <select className="form-control" onChange={this._onChangeGuild.bind(this)} value={this.state.guild}>
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
          <select className="form-control" onChange={this._onChangeFraction.bind(this)} value={this.state.fraction}>
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
        <select className="form-control" onChange={this._onChangeCharacter.bind(this)} value={this.state.character}>
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

  _onChangeAccessType(event) {
    if (event.target.value === 'none') {
      this.setState({accessType: 'none', world: 'none', guild: 'none'}, () => {
        this._getEvents()
      })
    } else {
      this.setState({accessType: event.target.value, world: 'none', guild: 'none'}, () => {
        this._getEvents()
      })
    }
  }

  _onChangeWorld(event) {
    this.setState({world: event.target.value}, () => {
      this._getEvents()
    })
  }

  _onChangeGuild(event) {
    this.setState({guild: event.target.value}, () => {
      this._getEvents()
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value}, () => {
      this._getEvents()
    })
  }

  _onChangeCharacter(event) {
    this.setState({character: event.target.value}, () => {
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
      previousDaysAmount: previous,
      daysAmount: (new Date(currentYear, currentMonth, 0)).getDate(),
      currentYear: currentYear,
      currentMonth: currentMonth
    })
  }

  render() {
    return (
      <div className="events">
        {this._renderFilters()}
        <div className="calendar_arrows">
          <button className="btn btn-primary btn-sm with_right_margin" onClick={this._onChangeMonth.bind(this, -1)}>{strings.previous}</button>
          <button className="btn btn-primary btn-sm" onClick={this._onChangeMonth.bind(this, 1)}>{strings.next}</button>
        </div>
        <div className="calendar">
          {this._renderPreviousMonth('previous')}
          {this._renderMonthDays()}
          {this._renderPreviousMonth('next')}
        </div>
      </div>
    )
  }
}
