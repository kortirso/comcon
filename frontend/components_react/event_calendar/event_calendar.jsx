import React from "react"

const $ = require("jquery")

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
    // define url with filters
    let url = '/events.json'
    if (params.length > 0) url = url + '?' + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({events: data})
      }
    })
  }

  _getFilterValues() {
    $.ajax({
      method: 'GET',
      url: '/events/filter_values.json',
      success: (data) => {
        console.log(data)
        this.setState({worlds: data.worlds, fractions: data.fractions, guilds: data.guilds, characters: data.characters})
      }
    })
  }

  _renderPreviousMonth() {
    let days = []
    for (let i = 0; i < this.state.previousDaysAmount; i++) {
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
        <a className="event" key={event.id} href={`/events/${event.slug}`}>
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
        <p>Filter by access type</p>
        <select className="form-control" onChange={this._onChangeAccessType.bind(this)} value={this.state.accessType}>
          <option value='none'>none</option>
          <option value='World'>Only worlds</option>
          <option value='Guild'>Only guilds</option>
        </select>
      </div>
    )
  }

  _renderWorldFilter() {
    if (this.state.accessType !== 'World') return false
    else {
      return (
        <div className="filter world">
          <p>Filter by world</p>
          <select className="form-control" onChange={this._onChangeWorld.bind(this)} value={this.state.world}>
            <option value='none' key='0'>none</option>
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
          <p>Filter by guild</p>
          <select className="form-control" onChange={this._onChangeGuild.bind(this)} value={this.state.guild}>
            <option value='none' key='0'>none</option>
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
          <p>Filter by fraction</p>
          <select className="form-control" onChange={this._onChangeFraction.bind(this)} value={this.state.fraction}>
            <option value='none' key='0'>none</option>
            {this._renderFractionsList()}
          </select>
        </div>
      )
    }
  }

  _renderFractionsList() {
    return this.state.fractions.map((fraction) => {
      return <option value={fraction.id} key={fraction.id}>{fraction.name.en}</option>
    })
  }

  _renderCharacterFilter() {
    return (
      <div className="filter character">
        <p>Filter by character</p>
        <select className="form-control" onChange={this._onChangeCharacter.bind(this)} value={this.state.character}>
          <option value='none' key='0'>none</option>
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

  render() {
    return (
      <div className="events">
        {this._renderFilters()}
        <div className="calendar">
          {this._renderPreviousMonth()}
          {this._renderMonthDays()}
        </div>
      </div>
    )
  }
}
