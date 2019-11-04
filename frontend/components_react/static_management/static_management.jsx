import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

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
      members: [],
      memberIds: [],
      invites: [],
      inviteIds: [],
      query: '',
      searchedCharacters: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getStaticMembers()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getStaticMembers() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/statics/${this.props.static_id}/members.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const memberIds = data.members.map((member) => {
          return member.character.id
        })
        const invites = data.invites.filter((invite) => {
          return ['send', 'declined'].includes(invite.status)
        })
        const inviteIds = invites.map((invite) => {
          return invite.character.id
        })
        this.setState({members: data.members, memberIds: memberIds, invites: invites, inviteIds: inviteIds})
      }
    })
  }

  _searchCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.props.world_id}&fraction_id=${this.props.fraction_id}`,
      success: (data) => {
        const characters = data.characters.filter((character) => {
          return !this.state.memberIds.includes(character.id) && !this.state.inviteIds.includes(character.id)
        })
        this.setState({searchedCharacters: characters})
      }
    })
  }

  _onInviteCharacter(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/static_invites.json?access_token=${this.props.access_token}`,
      data: { static_invite: { static_id: this.props.static_id, character_id: character.id } },
      success: (data) => {
        const searchedCharacters = [... this.state.searchedCharacters]
        const searchedCharacterIndex = searchedCharacters.indexOf(character)
        searchedCharacters.splice(searchedCharacterIndex, 1)
        if (data.character !== undefined) {
          let members = this.state.members
          members.push(data.character)
          let memberIds = this.state.memberIds
          memberIds.push(data.character.id)
          this.setState({members: members, memberIds: memberIds, searchedCharacters: searchedCharacters})
        } else if (data.invite !== undefined) {
          let invites = this.state.invites
          invites.push(data.invite)
          let inviteIds = this.state.inviteIds
          inviteIds.push(data.invite.character.id)
          this.setState({invites: invites, inviteIds: inviteIds, searchedCharacters: searchedCharacters})
        }
      }
    })
  }

  _onDeleteInvite(invite) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/static_invites/${invite.id}.json?access_token=${this.props.access_token}`,
      success: () => {
        const invites = [... this.state.invites]
        const inviteIndex = invites.indexOf(invite)
        invites.splice(inviteIndex, 1)
        const inviteIds = [... this.state.inviteIds]
        const inviteIdIndex = inviteIds.indexOf(invite.id)
        inviteIds.splice(inviteIdIndex, 1)
        this.setState({invites: invites, inviteIds: inviteIds})
      }
    })
  }

  _onDeleteStaticMember(member) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/static_members/${member.id}.json?access_token=${this.props.access_token}`,
      success: () => {
        const members = [... this.state.members]
        const memberIndex = members.indexOf(member)
        members.splice(memberIndex, 1)
        const memberIds = [... this.state.memberIds]
        const memberIdIndex = memberIds.indexOf(member.character.id)
        memberIds.splice(memberIdIndex, 1)
        this.setState({members: members, memberIds: memberIds})
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

  _renderInvites() {
    if (this.state.invites.length === 0) return <p>{strings.noInvites}</p>
    else {
      return (
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.race}</th>
              <th>{strings.level}</th>
              <th>{strings.guild}</th>
              <th></th>
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
    return this.state.invites.map((invite) => {
      return (
        <tr className={invite.character.character_class.en} key={invite.id}>
          <td>{invite.character.name}</td>
          <td>{invite.character.race[this.props.locale]}</td>
          <td>{invite.character.level}</td>
          <td>{invite.character.guild}</td>
          <td>
            {invite.status === 'declined' &&
              <input type="submit" name="commit" value={strings.deleteInvite} className="btn btn-primary btn-sm" onClick={this._onDeleteInvite.bind(this, invite)} />
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
              <th>{strings.race}</th>
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
        <tr className={character.character_class.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>{character.guild}</td>
          <td>
            <input type="submit" name="commit" value={strings.invite} className="btn btn-primary btn-sm" onClick={this._onInviteCharacter.bind(this, character)} />
          </td>
        </tr>
      )
    })
  }

  _renderStaticMembers() {
    return this.state.members.map((member) => {
      return (
        <tr className={member.character.character_class.en} key={member.id}>
          <td>{member.character.name}</td>
          <td>{member.character.race[this.props.locale]}</td>
          <td>{member.character.level}</td>
          <td>{member.character.guild}</td>
          <td>
            <button data-confirm={strings.sure} className="btn btn-primary btn-sm" onClick={this._onDeleteStaticMember.bind(this, member)}>{strings.deleteInvite}</button>
          </td>
        </tr>
      )
    })
  }

  render() {
    return (
      <div className="static_management">
        <div className="members">
          <h2>{strings.alreadyMembers}</h2>
          <table className="table table-sm">
            <thead>
              <tr>
                <th>{strings.name}</th>
                <th>{strings.race}</th>
                <th>{strings.level}</th>
                <th>{strings.guild}</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {this._renderStaticMembers()}
            </tbody>
          </table>
        </div>
        <div className="double_line">
          <div className="form-group invites">
            <h3>{strings.invites}</h3>
            {this._renderInvites()}
          </div>
          <div className="form-group search">
            <h3>{strings.search}</h3>
            <input placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
            {this._renderSearchedCharacters()}
          </div>
        </div>
      </div>
    )
  }
}
