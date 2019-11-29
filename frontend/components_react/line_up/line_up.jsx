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

const subscribeRoleValues = {
  Tank: 2,
  Healer: 1,
  Dd: 0
}

const statusValues = {
  approved: 2,
  reserve: 1,
  signed: 0
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
      commentValue: '',
      showApprovingBox: false,
      approvingSubscribe: null,
      approvingRole: '',
      approvingStatus: '',
      alternativeRender: false
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
        this.setState({subscribes: subscribes, showApprovingBox: false, approvingSubscribe: null, approvingRole: '', approvingStatus: ''})
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
    subscribes.sort((a, b) => this._sortCharacterFunction(a.character, b.character, a, b, status))
    return subscribes.map((subscribe) => {
      return (
        <tr className={subscribe.character.character_class_name.en} key={subscribe.id}>
          <td>
            <div className="character_name">{subscribe.character.name}</div>
          </td>
          <td>
            <div className="role_icons">
              {["approved", "reserve"].includes(status) && subscribe.for_role !== null ? this._renderSubscribedRole(subscribe.for_role) : this._renderRoles(subscribe.character.roles)}
            </div>
          </td>
          <td>{subscribe.character.level}</td>
          <td>{subscribe.character.guild_name}</td>
          <td>{strings[subscribe.status]}</td>
          <td className="comment_box">{this._renderComment(subscribe)}</td>
          <td>
            <div className="buttons">
              {this._checkAdminButton(subscribe.character, status) && this._renderAdminButton(subscribe)}
              {this.props.current_user_id === subscribe.character.user_id && this._renderUserButton(subscribe, status)}
            </div>
          </td>
        </tr>
      )
    })
  }

  _renderSubscribedRole(role) {
    if (role === 'Tank' || role === 'Healer') return <div className={`role_icon ${role}`}></div>
    else return <div className="role_icon Melee"></div>
  }

  _renderRoles(roles) {
    return roles.map((role, index) => {
      return <div className={`role_icon ${role.en}`} key={index}></div>
    })
  }

  _renderEmptyLine() {
    return (
      <tr className='empty_line'>
        <td colSpan={7}></td>
      </tr>
    )
  }

  _sortCharacterFunction(a, b, subscribeA, subscribeB, status) {
    let roleValueA
    let roleValueB
    if (["approved", "reserve"].includes(status)) {
      roleValueA = subscribeRoleValues[subscribeA.for_role]
      roleValueB = subscribeRoleValues[subscribeB.for_role]
    } else {
      roleValueA = roleValues[a.roles[0].en]
      roleValueB = roleValues[b.roles[0].en]
    }
    if (roleValueA > roleValueB) return -1
    else if (roleValueA < roleValueB) return 1
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

  _checkAdminButton(character, status) {
    if (!["approved", "reserve", "signed"].includes(status)) return false
    if (this.props.is_owner) return true
    else if (this.props.guild_role === null) return false
    else if (this.props.guild_role[0] === 'rl') return true
    else return this.props.guild_role[0] === 'cl' && this.props.guild_role[1].includes(character.character_class_name.en)
  }

  _renderAdminButton(subscribe) {
    return <button className={`btn-plus`} onClick={() => this._showApprovingBox(subscribe)}></button>
  }

  _showApprovingBox(subscribe) {
    this.setState({showApprovingBox: true, approvingSubscribe: subscribe, approvingRole: subscribe.character.roles[0][this.props.locale], approvingStatus: 'approved'})
  }

  _onApproveSubscribe() {
    this.onUpdateSubscribe(this.state.approvingSubscribe, { status: this.state.approvingStatus, for_role: this._modifyRole(this.state.approvingRole) })
  }

  _modifyRole(role) {
    if (['Tank', 'Танк'].includes(role)) return 'Tank'
    else if (['Healer', 'Лекарь'].includes(role)) return 'Healer'
    else return 'Dd'
  }

  _renderUserButton(subscribe, status) {
    if (!this.props.event_is_open) return false
    let buttons = []
    if (status !== 'signed') buttons.push(<button key='0' className="btn btn-primary btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: 'signed' })}>{strings.signed}</button>)
    if (status !== 'unknown') buttons.push(<button key='2' className="btn btn-primary btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: 'unknown' })}>{strings.unknown}</button>)
    if (status !== 'rejected') buttons.push(<button key='1' className="btn btn-primary btn-sm" onClick={this.onUpdateSubscribe.bind(this, subscribe, { status: 'rejected' })}>{strings.rejected}</button>)
    return <div className="user_buttons">{buttons}</div>
  }

  _renderRLBlock() {
    const approvedSubscribes = this.state.subscribes.filter((subscribe) => {
      return subscribe.status === 'approved'
    })
    return (
      <div>
        <p>{strings.approvedCharacters} - {approvedSubscribes.length}</p>
        {(this.props.is_owner || this.props.guild_role !== null) &&
          <div className="copy_raid">
            <button className="btn btn-primary btn-sm" onClick={this._copyRaid.bind(this)}>{strings.copy}</button>
            <textarea type="text" id="copyRaid" defaultValue={this._renderSubscribeCharacters(approvedSubscribes)} />
          </div>
        }
      </div>
    )
  }

  _renderSubscribeCharacters(subscribes) {
    return subscribes.map((subscribe) => {
      return subscribe.character.name
    }).join("\n")
  }

  _copyRaid() {
    const copiedBlock = document.getElementById("copyRaid")
    copiedBlock.select()
    copiedBlock.setSelectionRange(0, 99999)
    document.execCommand("copy")
  }

  _renderAvailableRoles(roles) {
    return roles.map((role, index) => {
      return <option value={role[this.props.locale]} key={index}>{role[this.props.locale]}</option>
    })
  }

  _transformRole(role) {
    if (role === 'Melee' || role === 'Ranged') return 'Dd'
    else return role
  }

  _renderClassList(roleName, characterClassName) {
    let subscribes = this.state.subscribes.filter((subscribe) => {
      if (!["signed", "reserve", "approved"].includes(subscribe.status)) return false
      else if (subscribe.character.character_class_name.en !== characterClassName) return false
      else if (subscribe.for_role !== null && subscribe.for_role !== roleName) return false
      else if (subscribe.for_role === null && this._transformRole(subscribe.character.roles[0].en) !== roleName) return false
      else return true
    })
    subscribes.sort((a, b) => this._sortCharacterAlternative(a, b))
    return subscribes.map((subscribe, index) => {
      return (
        <div className="subscribe" key={index}>
          <span>{subscribe.character.name}</span>
          <span>{strings[subscribe.status]}</span>
          <span>{this._checkAdminButton(subscribe.character, subscribe.status) && this._renderAdminButton(subscribe)}</span>
        </div>
      )
    })
  }

  _sortCharacterAlternative(a, b) {
    if (statusValues[a.status] > statusValues[b.status]) return -1
    else if (statusValues[a.status] < statusValues[b.status]) return 1
    else {
      if (a.character.level > b.character.level) return -1
      else if (a.character.level < b.character.level) return 1
      else {
        if (a.character.name <= b.character.name) return -1
        else return 1
      }
    }
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
            {this._renderRLBlock()}
          </div>
        }
        <div className="form-group form-check">
          <input className="form-check-input" type="checkbox" checked={this.state.alternativeRender} onChange={() => this.setState({alternativeRender: !this.state.alternativeRender})} id="alternative_checkbox" />
          <label htmlFor="alternative_checkbox">Alternative renderer</label>
        </div>
        {this._renderSignBlock()}
        {this.state.showApprovingBox &&
          <div className="approving_box">
            <p className="approving_box_title">{strings.form}</p>
            <p className="approving_box_character">{this.state.approvingSubscribe.character.name}</p>
            <div className="form-group">
              <label htmlFor="signed_role">{strings.selectRole}</label>
              <select className="form-control form-control-sm" id="signed_role" onChange={(event) => this.setState({approvingRole: event.target.value})} value={this.state.approvingRole}>
                {this._renderAvailableRoles(this.state.approvingSubscribe.character.roles)}
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="signed_status">{strings.selectStatus}</label>
              <select className="form-control form-control-sm" id="signed_status" onChange={(event) => this.setState({approvingStatus: event.target.value})} value={this.state.approvingStatus}>
                <option value="approved" key={0}>{strings.approved}</option>
                <option value="reserve" key={1}>{strings.reserve}</option>
                <option value="signed" key={2}>{strings.signed}</option>
              </select>
              <button className="btn btn-primary btn-sm" onClick={() => this._onApproveSubscribe()}>{strings.apply}</button>
            </div>
          </div>
        }
        {this.state.alternativeRender && eventInfo !== null &&
          <div className="alternative_line_up">
            <div className="main_roles">
              <div className="role_type">
                <h2>Tanks</h2>
                <div className="classes">
                  <div className="class_list">
                    <h3 className="Warrior">4</h3>
                    {this._renderClassList("Tank", "Warrior")}
                  </div>
                  <div className="class_list">
                    <h3 className="Druid">4</h3>
                    {this._renderClassList("Tank", "Druid")}
                  </div>
                  {eventInfo.fraction_name.en === 'Alliance' &&
                    <div className="class_list">
                      <h3 className="Paladin">4</h3>
                      {this._renderClassList("Tank", "Paladin")}
                    </div>
                  }
                </div>
              </div>
              <div className="role_type">
                <h2>Healers</h2>
                <div className="classes">
                  {eventInfo.fraction_name.en === 'Horde' &&
                    <div className="class_list">
                      <h3 className="Shaman">4</h3>
                      {this._renderClassList("Healer", "Shaman")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Druid">4</h3>
                    {this._renderClassList("Healer", "Druid")}
                  </div>
                  {eventInfo.fraction_name.en === 'Alliance' &&
                    <div className="class_list">
                      <h3 className="Paladin">4</h3>
                      {this._renderClassList("Healer", "Paladin")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Priest">4</h3>
                    {this._renderClassList("Healer", "Priest")}
                  </div>
                </div>
              </div>
            </div>
            <div className="dd">
              <div className="role_type">
                <h2>Damage Dealers</h2>
                <div className="classes">
                  <div className="class_list">
                    <h3 className="Warrior">4</h3>
                    {this._renderClassList("Dd", "Warrior")}
                  </div>
                  <div className="class_list">
                    <h3 className="Druid">4</h3>
                    {this._renderClassList("Dd", "Druid")}
                  </div>
                  {eventInfo.fraction_name.en === 'Alliance' &&
                    <div className="class_list">
                      <h3 className="Paladin">4</h3>
                      {this._renderClassList("Dd", "Paladin")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Priest">4</h3>
                    {this._renderClassList("Dd", "Priest")}
                  </div>
                  {eventInfo.fraction_name.en === 'Horde' &&
                    <div className="class_list">
                      <h3 className="Shaman">4</h3>
                      {this._renderClassList("Dd", "Shaman")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Warlock">4</h3>
                    {this._renderClassList("Dd", "Warlock")}
                  </div>
                  <div className="class_list">
                    <h3 className="Mage">4</h3>
                    {this._renderClassList("Dd", "Mage")}
                  </div>
                  <div className="class_list">
                    <h3 className="Hunter">4</h3>
                    {this._renderClassList("Dd", "Hunter")}
                  </div>
                  <div className="class_list">
                    <h3 className="Rogue">4</h3>
                    {this._renderClassList("Dd", "Rogue")}
                  </div>
                </div>
              </div>
            </div>
          </div>
        }
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
              {this.state.alternativeRender === false && this._renderSubscribes('approved')}
              {this.state.alternativeRender === false && this._renderEmptyLine()}
              {this.state.alternativeRender === false && this._renderSubscribes('reserve')}
              {this.state.alternativeRender === false && this._renderEmptyLine()}
              {this.state.alternativeRender === false && this._renderSubscribes('signed')}
              {this.state.alternativeRender === false && this._renderEmptyLine()}
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
