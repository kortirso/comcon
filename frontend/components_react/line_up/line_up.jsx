import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class LineUp extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      userCharacters: [],
      characters: [],
      selectedCharacterForSign: null,
      approved: 0,
      signed: 0,
      unknown: 0,
      rejected: 0,
      eventInfo: null
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getEventsSubscribes()
  }

  _filterCharacters(characters) {
    return characters.filter((character) => {
      return character.subscribe_for_event === null
    })
  }

  _getEventsSubscribes() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/${this.props.event_id}/subscribers.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({eventInfo: data.event_info}, () => {
          this._setState(data)
        })
      }
    })
  }

  onCreateSubscribe(status, event) {
    event.preventDefault()
    $.ajax({
      method: 'POST',
      url: `/api/v1/subscribes.json?access_token=${this.props.access_token}`,
      data: { subscribe: { character_id: this.state.selectedCharacterForSign, event_id: this.props.event_id, status: status } },
      success: (data) => {
        this._setState(data)
      }
    })
  }

  onUpdateSubscribe(subscribeId, status, event) {
    event.preventDefault()
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/subscribes/${subscribeId}.json?access_token=${this.props.access_token}`,
      data: { subscribe: { status: status } },
      success: (data) => {
        this._setState(data)
      }
    })
  }

  _calcEventListeners(characters) {
    let result = [0, 0, 0, 0]
    characters.forEach((character) => {
      switch (character.subscribe_for_event.status) {
        case 'approved':
          result[0] += 1
          break
        case 'signed':
          result[1] += 1
          break
        case 'unknown':
          result[2] += 1
          break
        case 'rejected':
          result[3] += 1
          break
      }
    })
    return result
  }

  _setState(data) {
    const userCharacters = this._filterCharacters(data.user_characters)
    const eventListeners = this._calcEventListeners(data.characters)
    this.setState({
      userCharacters: userCharacters,
      characters: data.characters,
      selectedCharacterForSign: userCharacters.length > 0 ? userCharacters[0].id : null,
      approved: eventListeners[0],
      signed: eventListeners[1],
      unknown: eventListeners[2],
      rejected: eventListeners[3]
    })
  }

  _renderSignBlock() {
    if (this.state.userCharacters.length === 0) return false
    if (!this.props.event_is_open) return false
    else {
      let characters = this.state.userCharacters.map((character) => {
        return <option value={character.id} key={character.id}>{character.name}</option>
      })
      return (
        <div className="user_signers">
          <p>{strings.signCharacter}</p>
          <select className="form-control form-control-sm" onChange={this._onChangeCharacter.bind(this)} value={this.state.selectedCharacterForSign}>
            {characters}
          </select>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'signed')}>{strings.subscribe}</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'unknown')}>{strings.unknown}</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'rejected')}>{strings.reject}</button>
        </div>
      )
    }
  }

  _onChangeCharacter(event) {
    this.setState({selectedCharacterForSign: event.target.value})
  }

  _renderSigners(option) {
    const characters = this.state.characters.filter((character) => {
      return (option === 'signers' && character.subscribe_for_event.status === 'signed') || (option === 'rejecters' && character.subscribe_for_event.status === 'rejected') || (option === 'unknown' && character.subscribe_for_event.status === 'unknown')
    })

    return (
      <table className="table table-sm">
        {this._renderTableHead()}
        <tbody>
          {this._renderSignersInTable(characters, option)}
        </tbody>
      </table>
    )
  }

  _renderSignersInTable(characters, option) {
    if (characters.length === 0) {
      return (
        <tr><td>{strings.noData}</td></tr>
      )
    } else {
      return characters.map((character) => {
        return (
          <tr className={character.character_class.en} key={character.id}>
            <td><div className="character_name">{character.name}{this._renderRoleIcons(character, option)}</div></td>
            <td>{character.level}</td>
            <td>{character.race[this.props.locale]}</td>
            <td>{character.character_class[this.props.locale]}</td>
            <td>{character.guild}</td>
            <td>
              <div className="buttons">
                {this._checkAdminButton(character, option) && this._renderAdminButton(character.subscribe_for_event.id, 'approved', strings.approve)}
                {this.props.current_user_id === character.user_id && this._renderUserButton(character.subscribe_for_event.id, option)}
              </div>
            </td>
          </tr>
        )
      })
    }
  }

  _renderUserButton(subscribeId, option) {
    if (!this.props.event_is_open) return false
    let buttons = []
    if (option !== 'signers') buttons.push(<button key='0' className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, 'signed')}>{strings.sign}</button>)
    if (option !== 'rejecters') buttons.push(<button key='1' className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, 'rejected')}>{strings.reject}</button>)
    if (option !== 'unknown') buttons.push(<button key='2' className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, 'unknown')}>{strings.unknown}</button>)
    return <div className="user_buttons">{buttons}</div>
  }

  _renderAdminButton(subscribeId, action, button) {
    return <button className="btn btn-light btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, action)}>{button}</button>
  }

  _renderRoleIcons(character, option) {
    if (option !== 'signers') return false
    else return <div className="role_icons"><div className={`role_icon ${character.main_role.en}`}></div></div>
  }

  _renderLineUp() {
    const characters = this.state.characters.filter((character) => {
      return character.subscribe_for_event.status === 'approved'
    })

    if (characters.length === 0) return false
    else {
      let lineUp = []
      const roles = [strings.tank, strings.healer, strings.melee, strings.ranged]
      roles.forEach((role, index) => {
        const chars = characters.filter((character) => {
          return character.main_role[this.props.locale] === role
        })

        lineUp.push(<tr key={index}><td colSpan="6" className="role_name">{role}</td></tr>)
        if (chars.length === 0) lineUp.push(<tr key={(index + 1) * 4}><td colSpan="6">{strings.noData}</td></tr>)
        else {
          chars.forEach((character) => {
            lineUp.push(
              <tr className={character.character_class.en} key={character.id}>
                <td><div className="character_name">{character.name}</div></td>
                <td>{character.level}</td>
                <td>{character.race[this.props.locale]}</td>
                <td>{character.character_class[this.props.locale]}</td>
                <td>{character.guild}</td>
                <td>
                  <div className="buttons">
                    {this._checkAdminButton(character, 'lineup') && this._renderAdminButton(character.subscribe_for_event.id, 'signed', strings.remove)}
                    {this.props.current_user_id === character.user_id && this._renderUserButton(character.subscribe_for_event.id, 'signers')}
                  </div>
                </td>
              </tr>
            )
          })
        }
      })

      return (
        <table className="table table-sm">
          {this._renderTableHead()}
          <tbody>
            {lineUp}
          </tbody>
        </table>
      )
    }
  }

  _checkAdminButton(character, option) {
    if (option !== 'signers' && option !== 'lineup') return false
    else if (this.props.is_owner) return true
    else if (this.props.guild_role === null) return false
    else if (this.props.guild_role[0] === 'rl') return true
    else return this.props.guild_role[0] === 'cl' && this.props.guild_role[1] === character.character_class.en
  }

  _renderTableHead() {
    return (
      <thead>
        <tr>
          <th>{strings.name}</th>
          <th>{strings.level}</th>
          <th>{strings.race}</th>
          <th>{strings.characterClass}</th>
          <th>{strings.guild}</th>
          <th></th>
        </tr>
      </thead>
    )
  }

  _renderLocalTime(time) {
    const date = new Date()
    let days = '0'
    let hours = time.hours - date.getTimezoneOffset() / 60
    if (hours < 0) {
      hours += 24
      days = '-1'
    } else if (hours > 24) {
      hours -= 24
      days = '+1'
    }
    const minutes = time.minutes
    return <span>{hours < 10 ? `0${hours}` : hours}:{minutes < 10 ? `0${minutes}` : minutes}{this._renderOtherDays(days)}</span>
  }

  _renderOtherDays(value) {
    if (value === '0') return false
    else return ` (${value})`
  }

  _renderAccess(eventInfo) {
    if (eventInfo.eventable_type === 'World') {
      return (
        strings.formatString(strings.worldEvent, {
          worldName: eventInfo.eventable_name,
          fraction: eventInfo.fraction_name
        })
      )
    } else if (eventInfo.eventable_type === 'Guild') {
      return (
        strings.formatString(strings.guildEvent, {
          guildName: eventInfo.eventable_name
        })
      )
    } else if (eventInfo.eventable_type === 'Static') {
      return (
        strings.formatString(strings.staticEvent, {
          staticName: eventInfo.eventable_name
        })
      )
    } 
  }

  render() {
    const eventInfo = this.state.eventInfo
    return (
      <div className="event">
        {eventInfo !== null &&
          <div className="event_details">
            <h2 className="event_name">{eventInfo.name}</h2>
            <p>{eventInfo.description}</p>
            {eventInfo.dungeon_name !== null &&
              <p className="event_location">{strings.eventLocation} - {eventInfo.dungeon_name[this.props.locale]}</p>
            }
            <p className="event_location">{strings.startTime} - {eventInfo.date} {this._renderLocalTime(eventInfo.time)}</p>
            <p>{this._renderAccess(eventInfo)}</p>
            <p>{strings.owner} - {eventInfo.owner_name}</p>
          </div>
        }
        <div className="line_up">
          <div className="approved">
            <div className="line_name">{strings.lineUp} ({this.state.approved})</div>
            {this._renderLineUp()}
          </div>
          <div className="signed">
            <div className="line_name">{strings.signers} ({this.state.signed})</div>
            {this._renderSignBlock()}
            {this._renderSigners('signers')}
          </div>
          <div className="unknown">
            <div className="line_name">{strings.unknown} ({this.state.unknown})</div>
            {this._renderSigners('unknown')}
          </div>
          <div className="rejected">
            <div className="line_name">{strings.rejected} ({this.state.rejected})</div>
            {this._renderSigners('rejecters')}
          </div>
        </div>
      </div>
    )
  }
}
