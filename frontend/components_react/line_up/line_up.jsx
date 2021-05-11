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
  signed: 0,
  declined: -1
}

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class LineUp extends React.Component {
  constructor() {
    super()
    this.typingTimeout = 0
    this.state = {
      eventInfo: null,
      subscribes: [],
      editMode: null,
      commentValue: '',
      showApprovingBox: false,
      approvingBoxForAdmin: true,
      approvingSubscribe: null,
      approvingRole: '',
      approvingStatus: '',
      alternativeRender: false,
      query: '',
      searchedCharacters: [],
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getEventInfo()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getEventInfo() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/${this.props.event_id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const alternativeRender = data.event !== null && data.event.group_role !== null
        this.setState({eventInfo: data.event, alternativeRender: alternativeRender}, () => {
          this._getEventsSubscribers()
        })
      }
    })
  }

  _getEventsSubscribers() {
    $.ajax({
      method: 'GET',
      url: `/api/v2/events/${this.props.event_id}/subscribers.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({subscribes: data.subscribers.data})
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
        subscribes[subscribeIndex] = data.subscribe.data
        this.setState({subscribes: subscribes, showApprovingBox: false, approvingSubscribe: null, approvingRole: '', approvingStatus: ''})
      }
    })
  }

  _onDeleteSubscribe(subscribe) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v2/subscribes/${subscribe.id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const subscribes = [... this.state.subscribes]
        const subscribeIndex = subscribes.indexOf(subscribe)
        subscribes.splice(subscribeIndex, 1)
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

  _onSendInvite(character) {
    let url = `/api/v1/subscribes.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { subscribe: { character_id: character.id, subscribeable_type: 'Event', subscribeable_id: this.props.event_id, status: 'created' } },
      success: (data) => {
        let subscribes = this.state.subscribes
        subscribes.push(data.subscribe.data)
        this.setState({subscribes: subscribes, searchedCharacters: [], query: ''})
      }
    })
  }

  _searchCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/search_for_event.json?access_token=${this.props.access_token}&query=${this.state.query}&event_id=${this.props.event_id}`,
      success: (data) => {
        this.setState({searchedCharacters: data.characters})
      }
    })
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
          fraction: eventInfo.fraction_name[this.props.locale]
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

  _renderSubscribes(status) {
    let subscribes = this.state.subscribes.filter((subscribe) => {
      return subscribe.attributes.status === status
    })
    subscribes.sort((a, b) => this._sortCharacterFunction(a, b, status))
    return subscribes.map((subscribe) => {
      const character = subscribe.attributes.character
      const characterAttrs = character.data.attributes
      return (
        <tr className={characterAttrs.character_class_name.en} key={subscribe.id}>
          <td className="character_name">
            <a href={this._defineCharacterLink(characterAttrs.slug)}>{characterAttrs.name}</a>
          </td>
          <td>
            <div className="role_icons">
              {["approved", "reserve"].includes(status) && subscribe.attributes.for_role !== null ? this._renderSubscribedRole(subscribe.attributes.for_role) : this._renderRoles(characterAttrs.roles)}
            </div>
          </td>
          <td>{characterAttrs.level}</td>
          <td>{characterAttrs.item_level > 0 && characterAttrs.item_level}</td>
          <td>{characterAttrs.guild_name}</td>
          <td>{strings[subscribe.attributes.status]}</td>
          <td className="comment_box">{this._renderComment(subscribe)}</td>
          <td>
            <div className="buttons">
              {this._checkAdminButton(character, status) && this._renderAdminButton(subscribe, '')}
              {this.props.event_is_open && this.props.current_user_id === characterAttrs.user_id && subscribe.attributes.status !== "declined" && this._renderUserButton(subscribe)}
              {this.props.current_user_id === characterAttrs.user_id && this._renderDeleteButton(subscribe)}
            </div>
          </td>
        </tr>
      )
    })
  }

  _defineCharacterLink(characterSlug) {
    return `${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters/${characterSlug}`
  }

  _renderSubscribedRole(role) {
    if (role === 'Tank' || role === 'Healer') return <div className={`role_icon ${role}`}></div>
    else return <div className="role_icon Melee"></div>
  }

  _renderRoles(roles) {
    return roles.map((role, index) => {
      return <div className={`role_icon ${role[0]}`} key={index}></div>
    })
  }

  _renderEmptyLine() {
    return (
      <tr className='empty_line'>
        <td colSpan={8}></td>
      </tr>
    )
  }

  _sortCharacterFunction(subscribeA, subscribeB, status) {
    const aCharacterAttrs = subscribeA.attributes.character.data.attributes
    const bCharacterAttrs = subscribeB.attributes.character.data.attributes
    let roleValueA
    let roleValueB
    if (["approved", "reserve"].includes(status)) {
      roleValueA = subscribeRoleValues[subscribeA.attributes.for_role]
      roleValueB = subscribeRoleValues[subscribeB.attributes.for_role]
    } else {
      roleValueA = roleValues[aCharacterAttrs.roles[0][0]]
      roleValueB = roleValues[bCharacterAttrs.roles[0][0]]
    }
    if (roleValueA > roleValueB) return -1
    else if (roleValueA < roleValueB) return 1
    else {
      if (aCharacterAttrs.character_class_name[this.props.locale] < bCharacterAttrs.character_class_name[this.props.locale]) return -1
      else if (aCharacterAttrs.character_class_name[this.props.locale] > bCharacterAttrs.character_class_name[this.props.locale]) return 1
      else {
        if (aCharacterAttrs.level > bCharacterAttrs.level) return -1
        else if (aCharacterAttrs.level < bCharacterAttrs.level) return 1
        else {
          if (aCharacterAttrs.name <= bCharacterAttrs.name) return -1
          else return 1
        }
      }
    }
  }

  _renderComment(subscribe) {
    const character = subscribe.attributes.character
    const characterAttrs = character.data.attributes
    if (this.state.editMode === subscribe.id) {
      return <textarea placeholder={strings.textarea} value={this.state.commentValue} onChange={(event) => this.setState({commentValue: event.target.value})} onKeyUp={this._onSaveComment.bind(this, subscribe)} />
    } else {
      if (this.props.current_user_id === characterAttrs.user_id) {
        const comment = subscribe.attributes.comment === null || subscribe.attributes.comment.length === 0 ? strings.textarea : subscribe.attributes.comment
        return <p className="user_comment" onClick={() => this.setState({editMode: subscribe.id, commentValue: ''})}>{comment}</p>
      }
      else return <p title={subscribe.attributes.comment}>{subscribe.attributes.comment}</p>
    }
  }

  _checkAdminButton(character, status) {
    if (!["approved", "reserve", "signed", "declined"].includes(status)) return false
    if (this.props.is_owner) return true
    else if (this.props.guild_role === null) return false
    else if (this.props.guild_role[0] === 'rl') return true
    else return this.props.guild_role[0] === 'cl' && this.props.guild_role[1].includes(character.data.attributes.character_class_name.en)
  }

  _renderAdminButton(subscribe, size) {
    return <button className={`btn btn-icon btn-edit ${size}`} onClick={() => this._showApprovingBox(subscribe, true)} aria-label="Edit button"></button>
  }

  _renderUserButton(subscribe) {
    return <button className="btn btn-icon btn-edit" onClick={() => this._showApprovingBox(subscribe, false)} aria-label="Edit button"></button>
  }

  _renderDeleteButton(subscribe) {
    return <button data-confirm={strings.sure} className="btn btn-icon btn-delete" onClick={() => this._onDeleteSubscribe(subscribe)} aria-label="Delete button"></button>
  }

  _showApprovingBox(subscribe, forAdmin) {
    this.setState({showApprovingBox: true, approvingBoxForAdmin: forAdmin, approvingSubscribe: subscribe, approvingRole: subscribe.attributes.character.data.attributes.roles[0][this.props.locale === 'en' ? 0 : 1], approvingStatus: forAdmin ? 'approved' : 'signed'})
  }

  closeModal() {
    this.setState({showApprovingBox: false, approvingBoxForAdmin: false, approvingSubscribe: null, approvingRole: '', approvingStatus: ''})
  }

  _onApproveSubscribe() {
    this.onUpdateSubscribe(this.state.approvingSubscribe, { status: this.state.approvingStatus, for_role: this._modifyRole(this.state.approvingRole) })
  }

  _modifyRole(role) {
    if (['Tank', 'Танк'].includes(role)) return 'Tank'
    else if (['Healer', 'Целитель'].includes(role)) return 'Healer'
    else return 'Dd'
  }

  _renderRLBlock() {
    const approvedSubscribes = this.state.subscribes.filter((subscribe) => {
      return subscribe.attributes.status === 'approved'
    })
    return (
      <div>
        <p>{strings.approvedCharacters} - {approvedSubscribes.length}</p>
        {(this.props.is_owner || this.props.guild_role !== null) &&
          <div className="copy_raid">
            <button className="btn btn-primary btn-sm" onClick={this._copyRaid.bind(this)}>{strings.copy}</button>
            <label htmlFor="copyRaid">Copy raid</label>
            <textarea type="text" id="copyRaid" defaultValue={this._renderSubscribeCharacters(approvedSubscribes)} />
          </div>
        }
      </div>
    )
  }

  _renderSubscribeCharacters(subscribes) {
    return subscribes.map((subscribe) => {
      return subscribe.attributes.character.data.attributes.name
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
      return <option value={role[this.props.locale === 'en' ? 0 : 1]} key={index}>{role[this.props.locale === 'en' ? 0 : 1]}</option>
    })
  }

  _transformRole(role) {
    if (role === 'Melee' || role === 'Ranged') return 'Dd'
    else return role
  }

  _renderModal() {
    if (!this.state.showApprovingBox) return false
    return (
      <div className={`modal fade ${this.state.showApprovingBox ? 'show' : ''}`} id="changeStatusModal" tabIndex="-1" role="dialog" aria-labelledby="changeStatusModalLabel" aria-hidden="true" onClick={this.closeModal.bind(this)}>
        <div className="modal-dialog" role="document" onClick={(e) => { e.stopPropagation() }}>
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="changeStatusModalLabel">{strings.form}</h5>
              <button type="button" className="close" onClick={() => this.closeModal()}>
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div className="modal-body">
              <p className="approving_box_character">{this.state.approvingSubscribe.attributes.character.data.attributes.name}</p>
              {this.state.approvingBoxForAdmin &&
                <div className="form-group">
                  <label htmlFor="signed_role">{strings.selectRole}</label>
                  <select className="form-control form-control-sm" id="signed_role" onChange={(event) => this.setState({approvingRole: event.target.value})} value={this.state.approvingRole}>
                    {this._renderAvailableRoles(this.state.approvingSubscribe.attributes.character.data.attributes.roles)}
                  </select>
                </div>
              }
              <div className="form-group">
                <label htmlFor="signed_status">{strings.selectStatus}</label>
                <select className="form-control form-control-sm" id="signed_status" onChange={(event) => this.setState({approvingStatus: event.target.value})} value={this.state.approvingStatus}>
                  {this.state.approvingBoxForAdmin && <option value="approved" key={0}>{strings.approved}</option>}
                  {this.state.approvingBoxForAdmin && <option value="reserve" key={1}>{strings.reserve}</option>}
                  <option value="signed" key={2}>{strings.signed}</option>
                  {this.state.approvingBoxForAdmin && <option value="declined" key={5}>{strings.declined}</option>}
                  {!this.state.approvingBoxForAdmin && <option value="unknown" key={3}>{strings.unknown}</option>}
                  {!this.state.approvingBoxForAdmin && <option value="rejected" key={4}>{strings.rejected}</option>}
                </select>
                <button className="btn btn-primary btn-sm with_top_margin" onClick={() => this._onApproveSubscribe()}>{strings.apply}</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  _renderClassList(roleName, characterClassName, needAmount) {
    let onlyApproved = 0
    let subscribes = this.state.subscribes.filter((subscribe) => {
      if (!["signed", "reserve", "approved"].includes(subscribe.attributes.status)) return false
      else if (subscribe.attributes.character.data.attributes.character_class_name.en !== characterClassName) return false
      else if (subscribe.attributes.for_role !== null && subscribe.attributes.for_role !== roleName) return false
      else if (subscribe.attributes.for_role === null && this._transformRole(subscribe.attributes.character.data.attributes.roles[0][0]) !== roleName) return false
      else {
        if (subscribe.attributes.status === "approved") onlyApproved += 1
        return true
      }
    })
    subscribes.sort((a, b) => this._sortCharacterAlternative(a, b))
    return (
      <div className="class_list">
        <h3 className={characterClassName}>{onlyApproved} / {needAmount}</h3>
        {this._renderAlternativeSubscribes(subscribes)}
      </div>
    )
  }

  _sortCharacterAlternative(a, b) {
    if (statusValues[a.attributes.status] > statusValues[b.attributes.status]) return -1
    else if (statusValues[a.attributes.status] < statusValues[b.attributes.status]) return 1
    else {
      if (a.attributes.character.data.attributes.level > b.attributes.character.data.attributes.level) return -1
      else if (a.attributes.character.data.attributes.level < b.attributes.character.data.attributes.level) return 1
      else {
        if (a.attributes.character.data.attributes.name <= b.attributes.character.data.attributes.name) return -1
        else return 1
      }
    }
  }

  _renderAlternativeSubscribes(subscribes) {
    return subscribes.map((subscribe, index) => {
      return (
        <div className="subscribe" key={index}>
          <span>
            <a href={this._defineCharacterLink(subscribe.attributes.character.data.attributes.slug)}>{subscribe.attributes.character.data.attributes.name}</a>
          </span>
          <span className={`status_icon ${subscribe.attributes.status} small`}></span>
          {this._checkAdminButton(subscribe.attributes.character, subscribe.attributes.status) &&
            <span>{this._renderAdminButton(subscribe, 'small')}</span>
          }
        </div>
      )
    })
  }

  _onChangeQuery(event) {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
    const queryValue = event.target.value
    if (queryValue.length < 3) return this.setState({query: queryValue})
    else this.setState({query: queryValue}, () => {
      this.typingTimeout = setTimeout(() => {
        this._searchCharacters()
      }, 1000)
    })
  }

  _renderSearchedCharacters() {
    if (this.state.searchedCharacters.length > 0) {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.level}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this._renderSearchResults()}
          </tbody>
        </table>
      )
    } else return <p>{strings.noCharacters}</p>
  }

  _renderSearchResults() {
    return this.state.searchedCharacters.map((character) => {
      return (
        <tr className={character.character_class_name.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.level}</td>
          <td>
            <input type="submit" name="commit" value={strings.invite} className="btn btn-primary btn-sm" onClick={this._onSendInvite.bind(this, character)} />
          </td>
        </tr>
      )
    })
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
            <div className="row">
              <div className="col-md-6">
                <p>{this._renderAccess(eventInfo)}</p>
                <p>{strings.owner} - {eventInfo.owner_name}</p>
                <p className="event_description">{eventInfo.description}</p>
                <p>{strings.formatString(strings.hoursBeforeClose, { hours: this.props.hours_before_close })}</p>
                {this._renderRLBlock()}
                {!this.props.event_is_open &&
                  <div className="event_closed">
                    <p className="alert alert-danger">{strings.closed}</p>
                  </div>
                }
              </div>
              {(this.props.is_owner || this.props.guild_role !== null) &&
                <div className="form-group search col-md-6">
                  <h3>{strings.search}</h3>
                  <input placeholder={strings.searchPlaceholder} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
                  {this._renderSearchedCharacters()}
                </div>
              }
            </div>
          </div>
        }
        {eventInfo !== null && eventInfo.group_role !== null &&
          <div className="form-group form-check">
            <input className="form-check-input" type="checkbox" checked={this.state.alternativeRender} onChange={() => this.setState({alternativeRender: !this.state.alternativeRender})} id="alternative_checkbox" />
            <label htmlFor="alternative_checkbox">{strings.alternative}</label>
          </div>
        }
        {this._renderModal()}
        {this.state.alternativeRender && eventInfo !== null &&
          <div className="alternative_line_up">
            <div className="main_roles">
              <div className="role_type">
                <h2>{strings.tanks}</h2>
                <div className="classes">
                  {this._renderClassList("Tank", "Warrior", eventInfo.group_role.tanks.by_class.warrior)}
                  {this._renderClassList("Tank", "Druid", eventInfo.group_role.tanks.by_class.druid)}
                  {this._renderClassList("Tank", "Paladin", eventInfo.group_role.tanks.by_class.paladin)}
                </div>
              </div>
              <div className="role_type">
                <h2>{strings.healers}</h2>
                <div className="classes">
                  {this._renderClassList("Healer", "Druid", eventInfo.group_role.healers.by_class.druid)}
                  {this._renderClassList("Healer", "Priest", eventInfo.group_role.healers.by_class.priest)}
                  {this._renderClassList("Healer", "Shaman", eventInfo.group_role.healers.by_class.shaman)}
                  {this._renderClassList("Healer", "Paladin", eventInfo.group_role.healers.by_class.paladin)}
                </div>
              </div>
            </div>
            <div className="dd">
              <div className="role_type">
                <h2>{strings.dd}</h2>
                <div className="classes">
                  {this._renderClassList("Dd", "Warrior", eventInfo.group_role.dd.by_class.warrior)}
                  {this._renderClassList("Dd", "Druid", eventInfo.group_role.dd.by_class.druid)}
                  {this._renderClassList("Dd", "Paladin", eventInfo.group_role.dd.by_class.paladin)}
                  {this._renderClassList("Dd", "Priest", eventInfo.group_role.dd.by_class.priest)}
                  {this._renderClassList("Dd", "Shaman", eventInfo.group_role.dd.by_class.shaman)}
                  {this._renderClassList("Dd", "Warlock", eventInfo.group_role.dd.by_class.warlock)}
                  {this._renderClassList("Dd", "Hunter", eventInfo.group_role.dd.by_class.hunter)}
                  {this._renderClassList("Dd", "Mage", eventInfo.group_role.dd.by_class.mage)}
                  {this._renderClassList("Dd", "Rogue", eventInfo.group_role.dd.by_class.rogue)}
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
                <th>{strings.itemLevel}</th>
                <th>{strings.guild}</th>
                <th>{strings.status}</th>
                <th>{strings.comment}</th>
                <th>{strings.operations}</th>
              </tr>
            </thead>
            <tbody>
              {this.state.alternativeRender === false && this._renderSubscribes('approved')}
              {this.state.alternativeRender === false && this._renderEmptyLine()}
              {this.state.alternativeRender === false && this._renderSubscribes('reserve')}
              {this.state.alternativeRender === false && this._renderEmptyLine()}
              {this.state.alternativeRender === false && this._renderSubscribes('signed')}
              {this.state.alternativeRender === false && this._renderEmptyLine()}
              {this._renderSubscribes('declined')}
              {this._renderEmptyLine()}
              {this._renderSubscribes('unknown')}
              {this._renderEmptyLine()}
              {this._renderSubscribes('rejected')}
              {this._renderEmptyLine()}
              {this._renderSubscribes('created')}
            </tbody>
          </table>
        </div>
      </div>
    )
  }
}
