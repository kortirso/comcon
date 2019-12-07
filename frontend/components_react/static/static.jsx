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
        let subscribes = this.state.subscribes
        subscribes.push(data.subscribe)
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
              {status === "approved" ? this._renderSubscribedRole(subscribe.for_role) : this._renderRoles(subscribe.character.roles)}
            </div>
          </td>
          <td>{subscribe.character.level}</td>
          <td>{subscribe.character.guild_name}</td>
          <td>{strings[subscribe.status]}</td>
          <td className="comment_box">{this._renderComment(subscribe)}</td>
          <td>
            <div className="buttons">
              {this.props.manager && <button className="btn-plus with_right_margin" onClick={() => this._showApprovingBox(subscribe, true)}></button>}
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

  _renderClassList(roleName, characterClassName) {
    let subscribes = this.state.subscribes.filter((subscribe) => {
      if (subscribe.character.character_class_name.en !== characterClassName) return false
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
          {this.props.manager &&
            <span><button className={`btn-plus`} onClick={() => this._showApprovingBox(subscribe, true)}></button></span>
          }
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

  render() {
    return (
      <div className="static">
        <div className="event_details form-group">
          <p>{this.props.static_description}</p>
        </div>
        <div className="form-group form-check">
          <input className="form-check-input" type="checkbox" checked={this.state.alternativeRender} onChange={() => this.setState({alternativeRender: !this.state.alternativeRender})} id="alternative_checkbox" />
          <label htmlFor="alternative_checkbox">{strings.alternative}</label>
        </div>
        {this._renderModal()}
        {this.state.alternativeRender &&
          <div className="alternative_line_up">
            <div className="main_roles">
              <div className="role_type">
                <h2>{strings.tanks}</h2>
                <div className="classes">
                  <div className="class_list">
                    <h3 className="Warrior">{this.props.static_group_role.tanks.by_class.warrior}</h3>
                    {this._renderClassList("Tank", "Warrior")}
                  </div>
                  <div className="class_list">
                    <h3 className="Druid">{this.props.static_group_role.tanks.by_class.druid}</h3>
                    {this._renderClassList("Tank", "Druid")}
                  </div>
                  {this.props.static_fraction_name === 'Alliance' &&
                    <div className="class_list">
                      <h3 className="Paladin">{this.props.static_group_role.tanks.by_class.paladin}</h3>
                      {this._renderClassList("Tank", "Paladin")}
                    </div>
                  }
                </div>
              </div>
              <div className="role_type">
                <h2>{strings.healers}</h2>
                <div className="classes">
                  {this.props.static_fraction_name === 'Horde' &&
                    <div className="class_list">
                      <h3 className="Shaman">{this.props.static_group_role.healers.by_class.shaman}</h3>
                      {this._renderClassList("Healer", "Shaman")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Druid">{this.props.static_group_role.healers.by_class.druid}</h3>
                    {this._renderClassList("Healer", "Druid")}
                  </div>
                  {this.props.static_fraction_name === 'Alliance' &&
                    <div className="class_list">
                      <h3 className="Paladin">{this.props.static_group_role.healers.by_class.paladin}</h3>
                      {this._renderClassList("Healer", "Paladin")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Priest">{this.props.static_group_role.healers.by_class.priest}</h3>
                    {this._renderClassList("Healer", "Priest")}
                  </div>
                </div>
              </div>
            </div>
            <div className="dd">
              <div className="role_type">
                <h2>{strings.dd}</h2>
                <div className="classes">
                  <div className="class_list">
                    <h3 className="Warrior">{this.props.static_group_role.dd.by_class.warrior}</h3>
                    {this._renderClassList("Dd", "Warrior")}
                  </div>
                  <div className="class_list">
                    <h3 className="Druid">{this.props.static_group_role.dd.by_class.druid}</h3>
                    {this._renderClassList("Dd", "Druid")}
                  </div>
                  {this.props.static_fraction_name === 'Alliance' &&
                    <div className="class_list">
                      <h3 className="Paladin">{this.props.static_group_role.dd.by_class.paladin}</h3>
                      {this._renderClassList("Dd", "Paladin")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Priest">{this.props.static_group_role.dd.by_class.priest}</h3>
                    {this._renderClassList("Dd", "Priest")}
                  </div>
                  {this.props.static_fraction_name === 'Horde' &&
                    <div className="class_list">
                      <h3 className="Shaman">{this.props.static_group_role.dd.by_class.shaman}</h3>
                      {this._renderClassList("Dd", "Shaman")}
                    </div>
                  }
                  <div className="class_list">
                    <h3 className="Warlock">{this.props.static_group_role.dd.by_class.warlock}</h3>
                    {this._renderClassList("Dd", "Warlock")}
                  </div>
                  <div className="class_list">
                    <h3 className="Mage">{this.props.static_group_role.dd.by_class.mage}</h3>
                    {this._renderClassList("Dd", "Mage")}
                  </div>
                  <div className="class_list">
                    <h3 className="Hunter">{this.props.static_group_role.dd.by_class.hunter}</h3>
                    {this._renderClassList("Dd", "Hunter")}
                  </div>
                  <div className="class_list">
                    <h3 className="Rogue">{this.props.static_group_role.dd.by_class.rogue}</h3>
                    {this._renderClassList("Dd", "Rogue")}
                  </div>
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
                  <th>{strings.guild}</th>
                  <th>{strings.status}</th>
                  <th>{strings.comment}</th>
                  <th></th>
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
