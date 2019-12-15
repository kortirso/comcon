import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

import ErrorView from '../error_view/error_view'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class StaticInviteFormForCharacter extends React.Component {
  constructor(props) {
    super(props)
    this.typingTimeout = 0
    this.state = {
      query: '',
      searchedStatics: [],
      errors: [],
      userRequests: [],
      staticInvites: [],
      characters: props.user_characters,
      characterId: props.user_characters.length === 0 ? null : props.user_characters[0].id,
      worldId: props.user_characters.length === 0 ? null : props.user_characters[0].world_id,
      staticId: props.user_characters.length === 0 ? null : props.user_characters[0].static_id
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    if (this.state.characterId !== null) this._getStaticInvites()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getStaticInvites() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/static_invites.json?access_token=${this.props.access_token}&character_id=${this.state.characterId}`,
      success: (data) => {
        const userRequests = data.static_invites.filter((staticInvite) => {
          return !staticInvite.from_static
        })
        const staticInvites = data.static_invites.filter((staticInvite) => {
          return staticInvite.from_static && staticInvite.status !== 'declined'
        })
        this.setState({userRequests: userRequests, staticInvites: staticInvites})
      }
    })
  }

  _searchStatics() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/statics/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.state.worldId}&fraction_id=${this.state.fractionId}`,
      success: (data) => {
        this.setState({searchedStatics: data.statics})
      }
    })
  }

  _onSendRequest(object) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/static_invites.json?access_token=${this.props.access_token}`,
      data: { static_invite: { static_id: object.id, character_id: this.state.characterId, from_static: false } },
      success: (data) => {
        const searchedStatics = [... this.state.searchedStatics]
        const staticIndex = searchedStatics.indexOf(object)
        searchedStatics.splice(staticIndex, 1)
        let userRequests = this.state.userRequests
        userRequests.push(data.invite)
        this.setState({searchedStatics: searchedStatics, userRequests: userRequests})
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onDeleteRequest(request) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/static_invites/${request.id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const userRequests = [... this.state.userRequests]
        const requestIndex = userRequests.indexOf(request)
        userRequests.splice(requestIndex, 1)
        this.setState({userRequests: userRequests})
      }
    })
  }

  _onSubmitInvite(invite, endpoint) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/static_invites/${invite.id}/${endpoint}.json?access_token=${this.props.access_token}`,
      data: {},
      success: (data) => {
        if (endpoint === 'decline') {
          const staticInvites = [... this.state.staticInvites]
          const inviteIndex = staticInvites.indexOf(invite)
          staticInvites.splice(inviteIndex, 1)
          this.setState({staticInvites: staticInvites})
        } else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      }
    })
  }

  _renderSearchedStatics() {
    if (this.state.searchedStatics.length > 0) {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
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
    return this.state.searchedStatics.map((object) => {
      return (
        <tr key={object.id}>
          <td>{object.name}</td>
          <td>
            <input type="submit" name="commit" value={strings.invite} className="btn btn-primary btn-sm" onClick={this._onSendRequest.bind(this, object)} />
          </td>
        </tr>
      )
    })
  }

  _renderUserRequests() {
    if (this.state.userRequests.length > 0) {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.status}</th>
              <th>{strings.operations}</th>
            </tr>
          </thead>
          <tbody>
            {this._renderUserRequestsResult()}
          </tbody>
        </table>
      )
    } else return <p>{strings.noRequests}</p>
  }

  _renderUserRequestsResult() {
    return this.state.userRequests.map((request) => {
      return (
        <tr key={request.id}>
          <td>{request.static_name}</td>
          <td>{strings[request.status]}</td>
          <td>
            <a className="btn btn-icon btn-delete" onClick={this._onDeleteRequest.bind(this, request)} aria-label="Delete button"></a>
          </td>
        </tr>
      )
    })
  }

  _renderStaticInvites() {
    if (this.state.staticInvites.length > 0) {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.status}</th>
              <th>{strings.operations}</th>
            </tr>
          </thead>
          <tbody>
            {this._renderStaticInvitesResults()}
          </tbody>
        </table>
      )
    } else return <p>{strings.noInvites}</p>
  }

  _renderStaticInvitesResults() {
    return this.state.staticInvites.map((invite) => {
      return (
        <tr key={invite.id}>
          <td>{invite.static_name}</td>
          <td>{strings[invite.status]}</td>
          <td>
            <input type="submit" name="commit" value={strings.approveInvite} className="btn btn-primary btn-sm with_right_margin" onClick={this._onSubmitInvite.bind(this, invite, 'approve')} />
            <input type="submit" name="commit" value={strings.declineInvite} className="btn btn-primary btn-sm" onClick={this._onSubmitInvite.bind(this, invite, 'decline')} />
          </td>
        </tr>
      )
    })
  }

  _onChangeQuery(event) {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
    const queryValue = event.target.value
    if (queryValue.length < 3) return this.setState({query: queryValue})
    else this.setState({query: queryValue}, () => {
      this.typingTimeout = setTimeout(() => {
        this._searchStatics()
      }, 1000)
    })
  }

  _renderCharacters() {
    return this.state.characters.map((character) => {
      return <option value={character.id} key={character.id}>{character.name}</option>
    })
  }

  _onChangeCharacter(event) {
    const currentCharacter = this.state.characters.filter((character) => {
      return character.id === parseInt(event.target.value)
    })[0]
    this.setState({characterId: event.target.value, worldId: currentCharacter.world_id, fractionId: currentCharacter.fraction_id}, () => {
      this._getStaticInvites()
    })
  }

  _returnSearchForm() {
    if (this.state.characters.length === 0) return false
    return (
      <div className="row">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="form-group search col-md-6">
          <div className="row">
            <div className="col-md-6">
              <div className="form-group">
                <label htmlFor="character_id">{strings.characters}</label>
                <select className="form-control form-control-sm" id="character_id" onChange={this._onChangeCharacter.bind(this)} value={this.state.characterId}>
                  {this._renderCharacters()}
                </select>
              </div>
            </div>
          </div>
          <h3>{strings.label}</h3>
          <input placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
          {this._renderSearchedStatics()}
        </div>
        <div className="form-group invites col-md-6">
          <h3>{strings.requestsLabel}</h3>
          {this._renderUserRequests()}
          <h3>{strings.invitesLabel}</h3>
          {this._renderStaticInvites()}
        </div>
      </div>
    )
  }

  render() {
    return (
      <div className="invite_form_for_character">
        {this._returnSearchForm()}
      </div>
    )
  }
}
