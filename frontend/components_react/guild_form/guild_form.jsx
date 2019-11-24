import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class GuildForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      guildId: props.guild_id,
      name: '',
      description: '',
      userCharacters: [],
      currentCharacterId: '0',
      errors: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getDefaultValues()
  }

  componentDidMount() {
    this._getGuild()
  }

  _getDefaultValues() {
    if (this.state.guildId !== undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/guilds/form_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({userCharacters: data.characters})
      }
    })
  }

  _getGuild() {
    if (this.state.guildId === undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/guilds/${this.state.guildId}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({name: data.guild.name, description: data.guild.description})
      }
    })
  }

  _onCreate() {
    const state = this.state
    let url = `/api/v1/guilds.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { guild: { name: state.name, description: state.description, owner_id: state.currentCharacterId } },
      success: (data) => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let url = `/api/v1/guilds/${this.state.guildId}.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: { guild: { name: state.name, description: state.description } },
      success: (data) => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _renderUserCharacters() {
    return this.state.userCharacters.map((character) => {
      return <option value={character.id} key={character.id}>{character.name}</option>
    })
  }

  _renderSubmitButton() {
    if (this.state.guildId === undefined) return <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
    return <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
  }

  render() {
    return (
      <div className="static_form">
        <h2>{this.state.guildId === undefined ? strings.newGuild : strings.updateGuild}</h2>
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="guild_name">{strings.name}</label>
              <input required="required" placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="guild_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
            </div>
            {this.state.guildId === undefined &&
              <div className="form-group">
                <label htmlFor="guild_owner_id">{strings.characterOwner}</label>
                <select className="form-control form-control-sm" id="guild_owner_id" onChange={(event) => this.setState({currentCharacterId: event.target.value})} value={this.state.currentCharacterId}>
                  <option value='0' key='0'></option>
                  {this._renderUserCharacters()}
                </select>
              </div>
            }
          </div>
          <div className="form-group">
            <label htmlFor="guild_description">{strings.description}</label>
            <textarea placeholder={strings.description} className="form-control form-control-sm" type="text" id="guild_description" value={this.state.description} onChange={(event) => this.setState({description: event.target.value})} />
          </div>
        </div>
        {this._renderSubmitButton()}
      </div>
    )
  }
}
