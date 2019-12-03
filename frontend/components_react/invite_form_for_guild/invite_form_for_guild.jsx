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

export default class InviteFormForGuild extends React.Component {
  constructor() {
    super()
    this.typingTimeout = 0
    this.state = {
      query: '',
      searchedCharacters: [],
      errors: [],
      guildInvites: [],
      userRequests: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getGuildInvites()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getGuildInvites() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/guild_invites.json?access_token=${this.props.access_token}&guild_id=${this.props.guild_id}`,
      success: (data) => {
        const userRequests = data.guild_invites.filter((guildInvite) => {
          return !guildInvite.from_guild && guildInvite.status !== 'declined'
        })
        const guildInvites = data.guild_invites.filter((guildInvite) => {
          return guildInvite.from_guild
        })
        this.setState({userRequests: userRequests, guildInvites: guildInvites})
      }
    })
  }

  _searchCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.props.world_id}&fraction_id=${this.props.fraction_id}`,
      success: (data) => {
        const characters = data.characters.filter((character) => {
          return character.guild_id === null
        })
        this.setState({searchedCharacters: characters})
      }
    })
  }

  _onSendInvite(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guild_invites.json?access_token=${this.props.access_token}`,
      data: { guild_invite: { guild_id: this.props.guild_id, character_id: character.id, from_guild: true } },
      success: (data) => {
        const searchedCharacters = [... this.state.searchedCharacters]
        const characterIndex = searchedCharacters.indexOf(character)
        searchedCharacters.splice(characterIndex, 1)
        let guildInvites = this.state.guildInvites
        guildInvites.push(data.guild_invite)
        this.setState({searchedCharacters: searchedCharacters, guildInvites: guildInvites})
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onDeleteInvite(invite) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/guild_invites/${invite.id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const guildInvites = [... this.state.guildInvites]
        const inviteIndex = guildInvites.indexOf(invite)
        guildInvites.splice(inviteIndex, 1)
        this.setState({guildInvites: guildInvites})
      }
    })
  }

  _onSubmitRequest(request, endpoint) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guild_invites/${request.id}/${endpoint}.json?access_token=${this.props.access_token}`,
      data: {},
      success: (data) => {
        const userRequests = [... this.state.userRequests]
        const requestIndex = userRequests.indexOf(request)
        userRequests.splice(requestIndex, 1)
        this.setState({userRequests: userRequests})
      }
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

  _renderGuildInvites() {
    if (this.state.guildInvites.length > 0) {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.level}</th>
              <th>{strings.status}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this._renderGuildInvitesResults()}
          </tbody>
        </table>
      )
    } else return <p>{strings.noInvites}</p>
  }

  _renderGuildInvitesResults() {
    return this.state.guildInvites.map((invite) => {
      return (
        <tr className={invite.character.character_class_name.en} key={invite.id}>
          <td>{invite.character.name}</td>
          <td>{invite.character.level}</td>
          <td>{invite.status}</td>
          <td>
            <input type="submit" name="commit" value={strings.deleteInvite} className="btn btn-primary btn-sm" onClick={this._onDeleteInvite.bind(this, invite)} />
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
              <th>{strings.level}</th>
              <th>{strings.status}</th>
              <th></th>
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
          <td>{request.status}</td>
          <td>
            <input type="submit" name="commit" value={strings.approveRequest} className="btn btn-primary btn-sm with_right_margin" onClick={this._onSubmitRequest.bind(this, request, 'approve')} />
            <input type="submit" name="commit" value={strings.declineRequest} className="btn btn-primary btn-sm" onClick={this._onSubmitRequest.bind(this, request, 'decline')} />
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
        this._searchCharacters()
      }, 1000)
    })
  }

  render() {
    return (
      <div className="invite_form_for_guild">
        <div className="row">
          <div className="form-group search col-md-6">
            {this.state.errors.length > 0 &&
              <ErrorView errors={this.state.errors} />
            }
            <h3>{strings.label}</h3>
            <input placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
            {this._renderSearchedCharacters()}
          </div>
          <div className="form-group invites col-md-6">
            <h3>{strings.requestsLabel}</h3>
            {this._renderGuildInvites()}
            <h3>{strings.invitesLabel}</h3>
            {this._renderUserRequests()}
          </div>
        </div>
      </div>
    )
  }
}
