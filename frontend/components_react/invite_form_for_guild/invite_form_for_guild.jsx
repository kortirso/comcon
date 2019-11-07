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
      errors: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _searchCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.props.world_id}&fraction_id=${this.props.fraction_id}`,
      success: (data) => {
        const characters = data.characters.filter((character) => {
          return character.guild === null
        })
        this.setState({searchedCharacters: characters})
      }
    })
  }

  _onInviteCharacter(character) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/guild_invites.json?access_token=${this.props.access_token}`,
      data: { guild_invite: { guild_id: this.props.guild_id, character_id: character.id, from_guild: true } },
      success: (data) => {
        const searchedCharacters = [... this.state.searchedCharacters]
        const characterIndex = searchedCharacters.indexOf(character)
        searchedCharacters.splice(characterIndex, 1)
        this.setState({searchedCharacters: searchedCharacters})
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
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
              <th>{strings.race}</th>
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
        <tr className={character.character_class.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>
            <input type="submit" name="commit" value={strings.invite} className="btn btn-primary btn-sm" onClick={this._onInviteCharacter.bind(this, character)} />
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
        <div className="double_line">
          <div className="form-group search">
            {this.state.errors.length > 0 &&
              <ErrorView errors={this.state.errors} />
            }
            <h3>{strings.label}</h3>
            <input placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
            {this._renderSearchedCharacters()}
          </div>
        </div>
      </div>
    )
  }
}
