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

export default class StaticForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      name: '',
      userCharacters: [],
      userGuilds: [],
      currentCharacterId: '0',
      currentGuildId: props.guild_id !== null && props.static_id === undefined ? props.guild_id : '0',
      description: '',
      staticId: props.static_id,
      privy: true,
      errors: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getDefaultValues()
  }

  _getDefaultValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/statics/form_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({userCharacters: data.characters, currentCharacterId: this.state.currentGuildId === '0' ? data.characters[0].id : '0', userGuilds: data.guilds}, () => {
          this._getStatic()
        })
      }
    })
  }

  _getStatic() {
    if (this.state.staticId === undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/statics/${this.state.staticId}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const object = data['static']
        this.setState({name: object.name, description: object.description, currentCharacterId: object.staticable_type === 'Character' ? object.staticable_id : '0', currentGuildId: object.staticable_type === 'Guild' ? object.staticable_id.toString() : '0', privy: object.privy})
      }
    })
  }

  _onCreate() {
    const state = this.state
    const staticableType = state.currentCharacterId === '0' ? 'Guild' : 'Character'
    const staticableId = state.currentCharacterId === '0' ? state.currentGuildId : state.currentCharacterId
    let url = `/api/v1/statics.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { static: { name: state.name, staticable_type: staticableType, staticable_id: staticableId, description: state.description, privy: state.privy } },
      success: (data) => {
        if (data['static'].guild_slug === null) window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/statics`)
        else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data['static'].guild_slug}/management`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let url = `/api/v1/statics/${this.state.staticId}.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: { static: { name: state.name, description: state.description, privy: state.privy } },
      success: (data) => {
        if (data['static'].guild_slug === null) window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/statics`)
        else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data['static'].guild_slug}/management`)
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

  _renderUserGuilds() {
    return this.state.userGuilds.map((guild) => {
      return <option value={guild.id} key={guild.id}>{guild.name}</option>
    })
  }

  _onCharacterChange(event) {
    if (event.target.value === '0') this.setState({currentCharacterId: '0'})
    else this.setState({currentCharacterId: event.target.value, currentGuildId: '0'})
  }

  _onGuildChange(event) {
    if (event.target.value === '0') this.setState({currentGuildId: '0'})
    else this.setState({currentGuildId: event.target.value, currentCharacterId: '0'})
  }

  _renderSubmitButton() {
    if (this.state.staticId === undefined) return <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
    return <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
  }

  render() {
    return (
      <div className="static_form">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <h2>{this.state.staticId === undefined ? strings.newStatic : strings.updateStatic}</h2>
        <div className="row">
          <div className="col-sm-6">
            <label htmlFor="static_name">{strings.name}</label>
            <input required="required" placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="static_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
          </div>
          <div className="col-sm-6 col-xl-3">
            <div className="form-group">
              <label htmlFor="static_character_id">{strings.characterOwner}</label>
              <select className="form-control form-control-sm" id="static_character_id" onChange={this._onCharacterChange.bind(this)} value={this.state.currentCharacterId} disabled={this.state.staticId !== undefined || this.props.guild_id !== null}>
                {this.state.currentGuildId !== '0' &&
                  <option value='0' key='0'></option>
                }
                {this._renderUserCharacters()}
              </select>
            </div>
          </div>
          <div className="col-sm-6 col-xl-3">
            <div className="form-group">
              <label htmlFor="static_guild_id">{strings.guildOwner}</label>
              <select className="form-control form-control-sm" id="static_guild_id" onChange={this._onGuildChange.bind(this)} value={this.state.currentGuildId} disabled={this.state.staticId !== undefined || this.props.guild_id !== null}>
                {this.state.currentCharacterId !== '0' &&
                  <option value='0' key='0'></option>
                }
                {this._renderUserGuilds()}
              </select>
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col-sm-6">
            <div className="form-group">
              <label htmlFor="static_description">{strings.description}</label>
              <textarea placeholder={strings.description} className="form-control form-control-sm" type="text" id="static_description" value={this.state.description} onChange={(event) => this.setState({description: event.target.value})} />
            </div>
          </div>
          <div className="col-sm-6">
            <div className="form-group">
              <div className="options">
                <p>{strings.options}</p>
                <div className="form-group form-check">
                  <input className="form-check-input" type="checkbox" checked={this.state.privy} onChange={() => this.setState({privy: !this.state.privy})} id="static_privy" />
                  <label htmlFor="static_privy">{strings.privy}</label>
                </div>
              </div>
            </div>
          </div>
        </div>
        {this._renderSubmitButton()}
      </div>
    )
  }
}
