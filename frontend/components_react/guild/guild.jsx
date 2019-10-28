import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

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

  _renderCharacters() {
    return this.state.characters.map((character) => {
      return (
        <tr className={character.character_class.en} key={character.id}>
          <td>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td></td>
        </tr>
      )
    })
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
