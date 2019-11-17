import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

import GuildRoleSelector from './guild_role_selector'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class Guild extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      characters: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  componentDidMount() {
    this._getCharacters()
  }

  _getCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/guilds/${this.props.guild_slug}/characters.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({characters: data.characters})
      }
    })
  }

  _createGuildRole(character, guildRole) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guild_roles.json?access_token=${this.props.access_token}`,
      data: { guild_role: { guild_id: this.props.guild_id, character_id: character.id, name: guildRole } },
      success: (data) => {
        this._updateCharacterGuildRole(character, data.guild_role)
      }
    })
  }

  _updateGuildRole(character, guildRole) {
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/guild_roles/${character.guild_role.id}.json?access_token=${this.props.access_token}`,
      data: { guild_role: { name: guildRole } },
      success: (data) => {
        this._updateCharacterGuildRole(character, data.guild_role)
      }
    })
  }

  _deleteGuildRole(character, guildRole) {
    $.ajax({
      method: 'DELETE',
      url: `/api/v1/guild_roles/${character.guild_role.id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this._updateCharacterGuildRole(character, null)
      }
    })
  }

  _onKickCharacter(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guilds/${this.props.guild_slug}/kick_character.json?access_token=${this.props.access_token}&character_id=${character.id}`,
      success: (data) => {
        const characters = [... this.state.characters]
        const characterIndex = characters.indexOf(character)
        characters.splice(characterIndex, 1)
        this.setState({characters: characters})
      }
    })
  }

  _onLeaveCharacter(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guilds/${this.props.guild_slug}/leave_character.json?access_token=${this.props.access_token}&character_id=${character.id}`,
      success: (data) => {
        const characters = [... this.state.characters]
        const characterIndex = characters.indexOf(character)
        characters.splice(characterIndex, 1)
        this.setState({characters: characters})
      }
    })
  }

  _updateCharacterGuildRole(character, guildRole) {
    const characters = [... this.state.characters]
    const characterIndex = characters.indexOf(character)
    characters[characterIndex].guild_role = guildRole
    this.setState({characters: characters})
  }

  _renderCharacters() {
    return this.state.characters.map((character) => {
      return (
        <tr className={character.character_class_name.en} key={character.id}>
          <td className='character_link' onClick={this._goToCharacter.bind(this, character.slug)}>{character.name}</td>
          <td>
            <div className="role_icons">
              <div className={`role_icon ${character.main_role_name.en}`}></div>
            </div>
          </td>
          <td>{character.race_name[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>{character.guild_role !== null ? strings[character.guild_role.name] : ''}</td>
          {this._renderManageButtons(character)}
        </tr>
      )
    })
  }

  _goToCharacter(characterSlug) {
    window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/characters/${characterSlug}`
  }

  _renderManageButtons(character) {
    if (!this.props.current_user_character_ids.includes(character.id) && (this.props.is_admin || this.props.is_gm)) {
      return (
        <td className="management_buttons">
          <GuildRoleSelector character={character} isAdmin={this.props.is_admin} isGmm={this.props.is_gm} locale={this.props.locale} onChangeGuildRole={this._onChangeGuildRole.bind(this)} />
          <button data-confirm={strings.sure} className="btn btn-primary btn-sm" onClick={this._onKickCharacter.bind(this, character)}>{strings.deleteButton}</button>
        </td>
      )
    } else if (this.props.current_user_character_ids.includes(character.id)) {
      return (
        <td className="management_buttons">
          <button data-confirm={strings.sure} className="btn btn-primary btn-sm" onClick={this._onLeaveCharacter.bind(this, character)}>{strings.leave}</button>
        </td>
      )
    } else return <td></td>
  }

  _onChangeGuildRole(characterId, guildRole) {
    const currentCharacter = this.state.characters.filter((character) => {
      return character.id === characterId
    })[0]
    if (currentCharacter.guild_role === null) this._createGuildRole(currentCharacter, guildRole)
    else if (guildRole !== '0') this._updateGuildRole(currentCharacter, guildRole)
    else this._deleteGuildRole(currentCharacter, guildRole)
  }

  render() {
    return (
      <div className="characters">
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.role}</th>
              <th>{strings.race}</th>
              <th>{strings.level}</th>
              <th>{strings.guildRole}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this._renderCharacters()}
          </tbody>
        </table>
      </div>
    )
  }
}
