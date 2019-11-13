import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

const roleValues = {
  Tank: 3,
  Healer: 2,
  Melee: 1,
  Ranged: 0
}

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class LineUp extends React.Component {
  constructor() {
    super()
    this.state = {
      eventInfo: null,
      subscribes: [],
      userCharacters: [],
      editMode: null,
      commentValue: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getEventInfo()
  }

  _filterCharacters(characters) {
    return characters.filter((character) => {
      return character.subscribe_for_event === null
    })
  }

  _getEventInfo() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/${this.props.event_id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({eventInfo: data.event}, () => {
          this._getEventsSubscribes()
        })
      }
    })
  }

  _getEventsSubscribes() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/${this.props.event_id}/subscribers.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({subscribes: data.subscribes}, () => {
          if (this.props.user_subscribed === false) this._getUserCharactersForEvent()
        })
      }
    })
  }

  _getUserCharactersForEvent() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/${this.props.event_id}/user_characters.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({userCharacters: data.user_characters, selectedCharacterForSign: data.user_characters[0][0]})
      }
    })
  }

  onCreateSubscribe(status) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/subscribes.json?access_token=${this.props.access_token}`,
      data: { subscribe: { character_id: this.state.selectedCharacterForSign, event_id: this.props.event_id, status: status } },
      success: (data) => {
        let subscribes = this.state.subscribes
        subscribes.push(data.subscribe)
        this.setState({subscribes: subscribes, userCharacters: [], selectedCharacterForSign: 0})
      }
    })
  }

  onUpdateSubscribe(subscribe, updatingData) {
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/subscribes/${subscribe.id}.json?access_token=${this.props.access_token}`,
      data: { subscribe: updatingData },
      success: (data) => {
        const subscribes = [... this.state.subscribes]
        const subscribeIndex = subscribes.indexOf(subscribe)
        subscribes[subscribeIndex] = data.subscribe
        this.setState({subscribes: subscribes})
      }
    })
  }

  _onSaveComment(subscribe, event) {
    if (event.key === 'Enter') {
      const nextCommentValue = this.state.commentValue
      this.setState({editMode: null, commentValue: ''}, () => {
        this.onUpdateSubscribe(subscribe, { comment: nextCommentValue.trim() })
      })
    }
  }

  _renderLocalTime(time) {
    const date = new Date()
    let days = '0'
    let hours = time.hours - (this.props.time_offset_value === null ? (date.getTimezoneOffset() / 60) : - this.props.time_offset_value)
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

  _renderSignBlock() {
    if (this.state.userCharacters.length === 0) return false
    if (!this.props.event_is_open) return false
    else {
      return (
        <div className="user_signers">
          <p>{strings.signCharacter}</p>
          <select className="form-control form-control-sm" onChange={this._onChangeCharacter.bind(this)} value={this.state.selectedCharacterForSign}>
            {this._renderUserCharacters()}
          </select>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'signed')}>{strings.signed}</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'unknown')}>{strings.unknown}</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'rejected')}>{strings.rejected}</button>
        </div>
      )
    }
  }

  _renderUserCharacters() {
    return this.state.userCharacters.map((character) => {
      return <option value={character[0]} key={character[0]}>{character[1]}</option>
    })
  }

  _onChangeCharacter(event) {
    this.setState({selectedCharacterForSign: event.target.value})
  }

  _renderSubscribes(status) {
    let subscribes = this.state.subscribes.filter((subscribe) => {
      return subscribe.status === status
    })
    subscribes.sort((a, b) => this._sortCharacterFunction(a.character, b.character))
    return subscribes.map((subscribe) => {
      return (
        <tr className={subscribe.character.character_class_name.en} key={subscribe.id}>
          <td>
            <div className="character_name">{subscribe.character.name}</div>
          </td>
          <td>
            {this._renderRoleIcons(subscribe.character, status)}
          </td>
          <td>{subscribe.character.level}</td>
          <td>{subscribe.character.guild_name}</td>
          <td>{strings[subscribe.status]}</td>
          <td className="comment_box">{this._renderComment(subscribe)}</td>
          <td>
            <div className="buttons">
              {this._checkAdminButton(subscribe.character, status) && this._renderAdminButton(subscribe, status)}
              {this.props.current_user_id === subscribe.character.user_id && this._renderUserButton(subscribe, status)}
            </div>
          </td>
        </tr>
      )
    })
  }

  _renderEmptyLine() {
    return (
      <tr className='empty_line'>
        <td colSpan={7}></td>
      </tr>
    )
  }

  _sortCharacterFunction(a, b) {
    if (roleValues[a.main_role_name.en] > roleValues[b.main_role_name.en]) return -1
    else if (roleValues[a.main_role_name.en] < roleValues[b.main_role_name.en]) return 1
    else {
      if (a.character_class_name[this.props.locale] < b.character_class_name[this.props.locale]) return -1
      else if (a.character_class_name[this.props.locale] > b.character_class_name[this.props.locale]) return 1
      else {
        if (a.level > b.level) return -1
        else if (a.level < b.level) return 1
        else {
          if (a.name <= b.name) return -1
          else return 1
        }
      }
    }
  }

  _renderComment(subscribe) {
    if (this.state.editMode === subscribe.id) {
      return <textarea placeholder={strings.textarea} value={this.state.commentValue} onChange={(event) => this.setState({commentValue: event.target.value})} onKeyUp={this._onSaveComment.bind(this, subscribe)} />
    } else {
      if (this.props.current_user_id === subscribe.character.user_id) {
        const comment = subscribe.comment === null || subscribe.comment.length === 0 ? strings.textarea : subscribe.comment
        return <p className="user_comment" onClick={() => this.setState({editMode: subscribe.id, commentValue: ''})}>{comment}</p>
      }
      else return <p title={subscribe.comment}>{subscribe.comment}</p>
    }
  }

  _renderRoleIcons(character, status) {
    return <div className="role_icons"><div className={`role_icon ${character.main_role_name.en}`}></div></div>
  }

  _checkAdminButton(character, status) {
    if (status !== 'signed' && status !== 'approved') return false
    else if (this.props.is_owner) return true
    else if (this.props.guild_role === null) return false
    else if (this.props.guild_role[0] === 'rl') return true
    else return this.props.guild_role[0] === 'cl' && this.props.guild_role[1] === character.character_class_name.en
  }

  _renderAdminButton(subscribe, status) {
    const buttonText = status === 'approved' ? '-' : '+'
    const nextStatus = status === 'approved' ? 'signed' : 'approved'
    return <button className="btn btn-light btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: nextStatus })}>{buttonText}</button>
  }

  _renderUserButton(subscribe, status) {
    if (!this.props.event_is_open) return false
    let buttons = []
    if (status !== 'signed') buttons.push(<button key='0' className="btn btn-primary btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: 'signed' })}>{strings.signed}</button>)
    if (status !== 'unknown') buttons.push(<button key='2' className="btn btn-primary btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: 'unknown' })}>{strings.unknown}</button>)
    if (status !== 'rejected') buttons.push(<button key='1' className="btn btn-primary btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: 'rejected' })}>{strings.rejected}</button>)
    return <div className="user_buttons">{buttons}</div>
  }

  render() {
    const eventInfo = this.state.eventInfo
    return (
      <div className="event">
        {eventInfo !== null &&
          <div className="event_details form-group">
            <div className="event_header">
              <h2 className="event_name">{eventInfo.name}</h2>
              <p className="event_location">{eventInfo.date} {this._renderLocalTime(eventInfo.time)}</p>
            </div>
            <p>{this._renderAccess(eventInfo)}</p>
            <p>{strings.owner} - {eventInfo.owner_name}</p>
            <p>{eventInfo.description}</p>
          </div>
        }
        {this._renderSignBlock()}
        <div className="line_up">
          <table className="table table-sm">
            <thead>
              <tr>
                <th>{strings.name}</th>
                <th>{strings.role}</th>
                <th>{strings.level}</th>
                <th>{strings.guild}</th>
                <th>{strings.status}</th>
                <th>{strings.comment}</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {this._renderSubscribes('approved')}
              {this._renderEmptyLine()}
              {this._renderSubscribes('signed')}
              {this._renderEmptyLine()}
              {this._renderSubscribes('unknown')}
              {this._renderEmptyLine()}
              {this._renderSubscribes('rejected')}
            </tbody>
          </table>
        </div>
      </div>
    )
  }
}
