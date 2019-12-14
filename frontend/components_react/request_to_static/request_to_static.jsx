import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'
import Alert from '../alert/alert'

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class RequestToStatic extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      characters: [],
      characterId: 0,
      errors: [],
      alert: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getCharacters()
  }

  _getCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/statics/${this.props.static_id}/characters_for_request.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({characters: data.characters})
      }
    })
  }

  _create() {
    $.ajax({
      method: 'POST',
      url: `/api/v1/static_invites.json?access_token=${this.props.access_token}`,
      data: { static_invite: { static_id: this.props.static_id, character_id: this.state.characterId, from_static: false } },
      success: (data) => {
        this.setState({alert: strings.success, errors: []}, () => {
          this._getCharacters()
        })
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors, alert: ''})
      }
    })
  }

  _renderCharacters() {
    return this.state.characters.map((character) => {
      return <option value={character.id} key={character.id}>{character.name}</option>
    })
  }

  render() {
    return (
      <div>
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        {this.state.alert !== '' &&
          <Alert type="success" value={this.state.alert} />
        }
        {this.state.characters.length > 0 &&
          <div className="static_invite_form">
            <div className="form-group">
              <label htmlFor="character_id">{strings.characters}</label>
              <select className="form-control form-control-sm" id="character_id" onChange={(event) => this.setState({characterId: event.target.value})} value={this.state.characterId}>
                <option value="0"></option>
                {this._renderCharacters()}
              </select>
            </div>
            <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={() => this._create()} />
          </div>
        }
      </div>
    )
  }
}
