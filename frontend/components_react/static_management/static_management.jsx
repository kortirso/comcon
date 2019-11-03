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
        const memberIds = data.characters.map((character) => {
          return character.id
        })
        this.setState({members: data.characters, memberIds: memberIds})
      }
    })
  }

  _searchCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/search.json?access_token=${this.props.access_token}&query=${this.state.query}&world_id=${this.props.world_id}&fraction_id=${this.props.fraction_id}`,
      success: (data) => {
        console.log(data)
        const characters = data.characters.filter((character) => {
          return !this.state.memberIds.includes(character.id)
        })
        this.setState({searchedCharacters: characters})
      }
    })
  }

  _renderStaticMembers() {
    return this.state.members.map((character) => {
      return (
        <tr className={character.character_class.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>{character.guild}</td>
          <td>{character.world}</td>
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
            </tr>
          </thead>
          <tbody>
            {this._renderSearchResults()}
          </tbody>
        </table>
      )
    } else return <p>No characters</p>
  }

  _renderSearchResults() {
    return this.state.searchedCharacters.map((character) => {
      return (
        <tr className={character.character_class.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>{character.guild}</td>
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
                <th>{strings.realm}</th>
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
