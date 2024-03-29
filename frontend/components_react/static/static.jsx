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
  reserve: 1
}

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class LineUp extends React.Component {
  constructor() {
    super()
    this.state = {
      subscribes: [],
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
    this._getStaticSubscribes()
  }

  _getStaticSubscribes() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/statics/${this.props.static_id}/subscribers.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({subscribes: data.subscribes})
      }
    })
  }

  onCreateSubscribe(status) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/subscribes.json?access_token=${this.props.access_token}`,
      data: { subscribe: { character_id: this.state.selectedCharacterForSign, subscribeable_id: this.props.static_id, subscribeable_type: 'Static', status: status } },
      success: (data) => {
        const updatedSubscribe = data.subscribe.data.attributes
        updatedSubscribe.character = updatedSubscribe.character.data.attributes

        const subscribes = this.state.subscribes
        subscribes.push(updatedSubscribe)
        this.setState({subscribes: subscribes})
      }
    })
  }

  onUpdateSubscribe(subscribe, updatingData) {
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/subscribes/${subscribe.id}.json?access_token=${this.props.access_token}`,
      data: { subscribe: updatingData },
      success: (data) => {
        const updatedSubscribe = data.subscribe.data.attributes
        updatedSubscribe.character = updatedSubscribe.character.data.attributes

        const subscribes = [... this.state.subscribes]
        const subscribeIndex = subscribes.indexOf(subscribe)
        subscribes[subscribeIndex] = updatedSubscribe
        this.setState({subscribes: subscribes, showApprovingBox: false, approvingSubscribe: null, approvingRole: '', approvingStatus: ''})
      }
    })
  }

  _onLeaveCharacter(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/statics/${this.props.static_id}/leave_character.json?access_token=${this.props.access_token}&character_id=${character.id}`,
      success: (data) => {
        window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/statics`
      }
    })
  }

  _kickCharacter(subscribe) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/statics/${this.props.static_id}/kick_character.json?access_token=${this.props.access_token}&character_id=${subscribe.character.id}`,
      success: (data) => {
        const subscribes = [... this.state.subscribes]
        const eventIndex = subscribes.indexOf(subscribe)
        subscribes.splice(eventIndex, 1)
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

  _renderSubscribes(status) {
    let subscribes = this.state.subscribes.filter((subscribe) => {
      return subscribe.status === status
    })
    subscribes.sort((a, b) => this._sortCharacterFunction(a.character, b.character, a, b, status))
    return subscribes.map((subscribe) => {
      return (
        <tr className={subscribe.character.character_class_name.en} key={subscribe.id}>
          <td>
            <a className="character_name" href={this._defineCharacterLink(subscribe.character.slug)}>{subscribe.character.name}</a>
          </td>
          <td>
            <div className="role_icons">
              {status === "approved" ? this._renderSubscribedRole(subscribe.for_role) : this._renderRoles(subscribe.character.roles)}
            </div>
          </td>
          <td>{subscribe.character.level}</td>
          <td>{subscribe.character.item_level > 0 && subscribe.character.item_level}</td>
          <td>{subscribe.character.guild_name}</td>
          <td>{strings[subscribe.status]}</td>
          <td className="comment_box">{this._renderComment(subscribe)}</td>
          <td>
            <div className="buttons">
              {this.props.manager && <button className="btn btn-icon btn-edit with_right_margin" onClick={() => this._showApprovingBox(subscribe, true)} aria-label="Edit button"></button>}
              {this.props.manager && <button className="btn btn-icon btn-delete with_right_margin" onClick={() => this._kickCharacter(subscribe)} aria-label="Kick button"></button>}
              {this.props.current_user_id === subscribe.character.user_id && <button data-confirm={strings.sure} className="btn btn-icon btn-exit" onClick={this._onLeaveCharacter.bind(this, subscribe.character)} aria-label="Edit button"></button>}
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
      return <div className={`role_icon ${role.en}`} key={index}></div>
    })
  }

  _renderEmptyLine() {
    return (
      <tr className='empty_line'>
        <td colSpan={8}></td>
      </tr>
    )
  }

  _sortCharacterFunction(a, b, subscribeA, subscribeB, status) {
    let roleValueA
    let roleValueB
    if (status === "approved") {
      roleValueA = subscribeRoleValues[subscribeA.for_role]
      roleValueB = subscribeRoleValues[subscribeB.for_role]
    } else if (status === "reserve") {
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

  _showApprovingBox(subscribe, forAdmin) {
    this.setState({showApprovingBox: true, approvingSubscribe: subscribe, approvingRole: subscribe.character.roles[0][this.props.locale], approvingStatus: forAdmin ? 'approved' : 'signed'})
  }

  closeModal() {
    this.setState({showApprovingBox: false, approvingSubscribe: null, approvingRole: '', approvingStatus: ''})
  }

  _onApproveSubscribe() {
    this.onUpdateSubscribe(this.state.approvingSubscribe, { status: this.state.approvingStatus, for_role: this._modifyRole(this.state.approvingRole) })
  }

  _modifyRole(role) {
    if (['Tank', 'Танк'].includes(role)) return 'Tank'
    else if (['Healer', 'Целитель'].includes(role)) return 'Healer'
    else return 'Dd'
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
      if (subscribe.character.character_class_name.en !== characterClassName) return false
      else if (subscribe.for_role !== null && subscribe.for_role !== roleName) return false
      else if (subscribe.for_role === null && this._transformRole(subscribe.character.roles[0].en) !== roleName) return false
      else {
        if (subscribe.status === "approved") onlyApproved += 1
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

  _renderAlternativeSubscribes(subscribes) {
    return subscribes.map((subscribe, index) => {
      return (
        <div className="subscribe" key={index}>
          <span>{subscribe.character.name}</span>
          <span className={`status_icon ${subscribe.status} small`}></span>
          {this.props.manager &&
            <span><button className={`btn btn-icon btn-edit small`} onClick={() => this._showApprovingBox(subscribe, true)} aria-label="Edit button"></button></span>
          }
        </div>
      )
    })
  }

  render() {
    return (
      <div className="static">
        {this.props.static_group_role !== null &&
          <div className="form-group form-check">
            <input className="form-check-input" type="checkbox" checked={this.state.alternativeRender} onChange={() => this.setState({alternativeRender: !this.state.alternativeRender})} id="alternative_checkbox" />
            <label htmlFor="alternative_checkbox">{strings.alternative}</label>
          </div>
        }
        {this._renderModal()}
        {this.state.alternativeRender &&
          <div className="alternative_line_up">
            <div className="main_roles">
              <div className="role_type">
                <h2>{strings.tanks}</h2>
                <div className="classes">
                  {this._renderClassList("Tank", "Warrior", this.props.static_group_role.tanks.by_class.warrior)}
                  {this._renderClassList("Tank", "Druid", this.props.static_group_role.tanks.by_class.druid)}
                  {this.props.static_fraction_name === 'Alliance' && this._renderClassList("Tank", "Paladin", this.props.static_group_role.tanks.by_class.paladin)}
                </div>
              </div>
              <div className="role_type">
                <h2>{strings.healers}</h2>
                <div className="classes">
                  {this._renderClassList("Healer", "Druid", this.props.static_group_role.healers.by_class.druid)}
                  {this._renderClassList("Healer", "Priest", this.props.static_group_role.healers.by_class.priest)}
                  {this.props.static_fraction_name === 'Horde' && this._renderClassList("Healer", "Shaman", this.props.static_group_role.healers.by_class.shaman)}
                  {this.props.static_fraction_name === 'Alliance' && this._renderClassList("Healer", "Paladin", this.props.static_group_role.healers.by_class.paladin)}
                </div>
              </div>
            </div>
            <div className="dd">
              <div className="role_type">
                <h2>{strings.dd}</h2>
                <div className="classes">
                  {this._renderClassList("Dd", "Warrior", this.props.static_group_role.dd.by_class.warrior)}
                  {this._renderClassList("Dd", "Druid", this.props.static_group_role.dd.by_class.druid)}
                  {this.props.static_fraction_name === 'Alliance' && this._renderClassList("Dd", "Paladin", this.props.static_group_role.dd.by_class.paladin)}
                  {this._renderClassList("Dd", "Priest", this.props.static_group_role.dd.by_class.priest)}
                  {this.props.static_fraction_name === 'Horde' && this._renderClassList("Dd", "Shaman", this.props.static_group_role.dd.by_class.shaman)}
                  {this._renderClassList("Dd", "Warlock", this.props.static_group_role.dd.by_class.warlock)}
                  {this._renderClassList("Dd", "Hunter", this.props.static_group_role.dd.by_class.hunter)}
                  {this._renderClassList("Dd", "Mage", this.props.static_group_role.dd.by_class.mage)}
                  {this._renderClassList("Dd", "Rogue", this.props.static_group_role.dd.by_class.rogue)}
                </div>
              </div>
            </div>
          </div>
        }
        {!this.state.alternativeRender &&
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
                {this._renderSubscribes('approved')}
                {this._renderEmptyLine()}
                {this._renderSubscribes('reserve')}
              </tbody>
            </table>
          </div>
        }
      </div>
    )
  }
}
