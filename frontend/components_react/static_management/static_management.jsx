import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

import ErrorView from '../error_view/error_view'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class StaticManagement extends React.Component {
  constructor() {
    super()
    this.typingTimeout = 0
    this.state = {
      query: '',
      searchedCharacters: [],
      errors: [],
      staticInvites: [],
      userRequests: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getStaticInvites()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getStaticInvites() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/static_invites.json?access_token=${this.props.access_token}&static_id=${this.props.static_id}`,
      success: (data) => {
        const userRequests = data.static_invites.filter((staticInvite) => {
          return !staticInvite.from_static && staticInvite.status !== 'declined'
        })
        const staticInvites = data.static_invites.filter((staticInvite) => {
          return staticInvite.from_static
        })
        this.setState({userRequests: userRequests, staticInvites: staticInvites})
      }
    })
  }

  _searchCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.props.world_id}&fraction_id=${this.props.fraction_id}`,
      success: (data) => {
        this.setState({searchedCharacters: data.characters})
      }
    })
  }

  _onInviteCharacter(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/static_invites.json?access_token=${this.props.access_token}`,
      data: { static_invite: { static_id: this.props.static_id, character_id: character.id, from_static: true } },
      success: (data) => {
        const searchedCharacters = [... this.state.searchedCharacters]
        const searchedCharacterIndex = searchedCharacters.indexOf(character)
        searchedCharacters.splice(searchedCharacterIndex, 1)
        if (data.member !== undefined) {
          this.setState({searchedCharacters: searchedCharacters})
        } else if (data.invite !== undefined) {
          let staticInvites = this.state.staticInvites
          staticInvites.push(data.invite)
          this.setState({staticInvites: staticInvites, searchedCharacters: searchedCharacters})
        }
      }
    })
  }

  _onDeleteInvite(invite) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/static_invites/${invite.id}.json?access_token=${this.props.access_token}`,
      success: () => {
        const staticInvites = [... this.state.staticInvites]
        const inviteIndex = staticInvites.indexOf(invite)
        staticInvites.splice(inviteIndex, 1)
        this.setState({staticInvites: staticInvites})
      }
    })
  }

  _onSubmitRequest(request, endpoint) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/static_invites/${request.id}/${endpoint}.json?access_token=${this.props.access_token}`,
      data: {},
      success: (data) => {
        const requests = [... this.state.requests]
        const requestIndex = requests.indexOf(request)
        requests.splice(requestIndex, 1)
        this.setState({requests: requests})
      }
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

  _renderRequests() {
    if (this.state.userRequests.length > 0) {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.level}</th>
              <th>{strings.guild}</th>
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
        <tr className={request.character.character_class_name.en} key={request.id}>
          <td>{request.character.name}</td>
          <td>{request.character.level}</td>
          <td>{request.character.guild_name}</td>
          <td>{strings[request.status]}</td>
          <td>
            <input type="submit" name="commit" value={strings.approveRequest} className="btn btn-primary btn-sm with_right_margin" onClick={this._onSubmitRequest.bind(this, request, 'approve')} />
            <input type="submit" name="commit" value={strings.declineRequest} className="btn btn-primary btn-sm" onClick={this._onSubmitRequest.bind(this, request, 'decline')} />
          </td>
        </tr>
      )
    })
  }

  _renderInvites() {
    if (this.state.staticInvites.length === 0) return <p>{strings.noInvites}</p>
    else {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.level}</th>
              <th>{strings.guild}</th>
              <th>{strings.status}</th>
              <th>{strings.operations}</th>
            </tr>
          </thead>
          <tbody>
            {this._renderInvitesResults()}
          </tbody>
        </table>
      )
    }
  }

  _renderInvitesResults() {
    return this.state.staticInvites.map((invite) => {
      return (
        <tr className={invite.character.character_class_name.en} key={invite.id}>
          <td>{invite.character.name}</td>
          <td>{invite.character.level}</td>
          <td>{invite.character.guild_name}</td>
          <td>{strings[invite.status]}</td>
          <td>
            {invite.status === 'declined' &&
              <a className="btn btn-icon btn-delete" onClick={this._onDeleteInvite.bind(this, invite)}></a>
            }
          </td>
        </tr>
      )
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
              <th>{strings.guild}</th>
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
          <td>{character.guild_name}</td>
          <td>
            <input type="submit" name="commit" value={strings.invite} className="btn btn-primary btn-sm" onClick={this._onInviteCharacter.bind(this, character)} />
          </td>
        </tr>
      )
    })
  }

  render() {
    return (
      <div className="static_management">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="row">
          <div className="form-group search col-md-6">
            <h3>{strings.search}</h3>
            <input placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
            {this._renderSearchedCharacters()}
          </div>
          <div className="form-group invites col-md-6">
            <h3>{strings.invites}</h3>
            {this._renderInvites()}
            <h3>{strings.requests}</h3>
            {this._renderRequests()}
          </div>
        </div>
      </div>
    )
  }
}
