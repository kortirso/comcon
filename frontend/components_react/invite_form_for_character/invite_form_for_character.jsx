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

export default class InviteFormForCharacter extends React.Component {
  constructor(props) {
    super(props)
    this.typingTimeout = 0
    this.state = {
      query: '',
      searchedGuilds: [],
      errors: [],
      userRequests: [],
      guildInvites: [],
      characters: props.user_characters,
      characterId: props.user_characters.length === 0 ? null : props.user_characters[0].id,
      worldId: props.user_characters.length === 0 ? null : props.user_characters[0].world_id,
      fractionId: props.user_characters.length === 0 ? null : props.user_characters[0].fraction_id
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    if (this.state.characterId !== null) this._getGuildInvites()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getGuildInvites() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/guild_invites.json?access_token=${this.props.access_token}&character_id=${this.state.characterId}`,
      success: (data) => {
        const userRequests = data.guild_invites.filter((guildInvite) => {
          return !guildInvite.from_guild
        })
        const guildInvites = data.guild_invites.filter((guildInvite) => {
          return guildInvite.from_guild && guildInvite.status !== 'declined'
        })
        this.setState({userRequests: userRequests, guildInvites: guildInvites})
      }
    })
  }

  _searchGuilds() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/guilds/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.state.worldId}&fraction_id=${this.state.fractionId}`,
      success: (data) => {
        this.setState({searchedGuilds: data.guilds})
      }
    })
  }

  _onSendRequest(guild) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guild_invites.json?access_token=${this.props.access_token}`,
      data: { guild_invite: { guild_id: guild.id, character_id: this.state.characterId, from_guild: false } },
      success: (data) => {
        if (data.result !== undefined && data.result === "Approved") window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/characters`
        else {
          const searchedGuilds = [... this.state.searchedGuilds]
          const guildIndex = searchedGuilds.indexOf(guild)
          searchedGuilds.splice(guildIndex, 1)
          let userRequests = this.state.userRequests
          userRequests.push(data.guild_invite)
          this.setState({searchedGuilds: searchedGuilds, userRequests: userRequests})
        }
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onDeleteRequest(request) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/guild_invites/${request.id}.json?access_token=${this.props.access_token}`,
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
      url: `/api/v1/guild_invites/${invite.id}/${endpoint}.json?access_token=${this.props.access_token}`,
      data: {},
      success: (data) => {
        if (endpoint === 'decline') {
          const guildInvites = [... this.state.guildInvites]
          const inviteIndex = guildInvites.indexOf(invite)
          guildInvites.splice(inviteIndex, 1)
          this.setState({guildInvites: guildInvites})
        } else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      }
    })
  }

  _renderSearchedGuilds() {
    if (this.state.searchedGuilds.length > 0) {
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
    return this.state.searchedGuilds.map((guild) => {
      return (
        <tr key={guild.id}>
          <td>{guild.name} - {guild.world_name}</td>
          <td>
            <input type="submit" name="commit" value={strings.invite} className="btn btn-primary btn-sm" onClick={this._onSendRequest.bind(this, guild)} />
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
        <tr key={request.id}>
          <td>{request.guild.name} - {request.guild.world_name}</td>
          <td>{strings[request.status]}</td>
          <td>
            <a className="btn btn-icon btn-delete" onClick={this._onDeleteRequest.bind(this, request)}></a>
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
        <tr key={invite.id}>
          <td>{invite.guild.name} - {invite.guild.world_name}</td>
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
        this._searchGuilds()
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
      this._getGuildInvites()
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
          {this._renderSearchedGuilds()}
        </div>
        <div className="form-group invites col-md-6">
          <h3>{strings.requestsLabel}</h3>
          {this._renderUserRequests()}
          <h3>{strings.invitesLabel}</h3>
          {this._renderGuildInvites()}
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
