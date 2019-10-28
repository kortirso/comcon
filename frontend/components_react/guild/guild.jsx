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

  _updateCharacterGuildRole(character, guildRole) {
    const characters = [... this.state.characters]
    const characterIndex = characters.indexOf(character)
    characters[characterIndex].guild_role = guildRole
    this.setState({characters: characters})
  }

  _renderCharacters() {
    return this.state.characters.map((character) => {
      return (
        <tr className={character.character_class.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>{character.guild_role !== null ? strings[character.guild_role.name] : ''}</td>
          <td>
            {this._renderRoleSelector(character)}
          </td>
        </tr>
      )
    })
  }

  _renderRoleSelector(character) {
    if (this.props.current_user_character_ids.includes(character.id)) return false
    else if (this.props.is_admin || this.props.is_gm) {
      return <GuildRoleSelector character={character} isAdmin={this.props.is_admin} isGmm={this.props.is_gm} locale={this.props.locale} onChangeGuildRole={this._onChangeGuildRole.bind(this)} />
    } else return false
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
        <table className="table">
          <thead>
            <tr>
              <th>{strings.name}</th>
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
