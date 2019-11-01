import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

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
        this.setState({userCharacters: data.characters, userGuilds: data.guilds}, () => {
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
        this.setState({name: object.name, description: object.description, currentCharacterId: object.staticable_type === 'Character' ? object.staticable_id : '0', currentGuildId: object.staticable_type === 'Guild' ? object.staticable_id : '0'})
      }
    })
  }

  _onCreate() {
    const state = this.state
    const staticableType = state.currentCharacterId === '0' ? 'Guild' : 'Character'
    const staticableId = state.currentCharacterId === '0' ? state.currentGuildId : state.currentCharacterId
    $.ajax({
      method: 'POST',
      url: `/api/v1/statics.json?access_token=${this.props.access_token}`,
      data: { static: { name: state.name, staticable_type: staticableType, staticable_id: staticableId, description: state.description } },
      success: (data) => {
        if (data['static'].guild_slug === null) window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/statics`)
        else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data['static'].guild_slug}/management`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
      }
    })
  }

  _onUpdate() {
    const state = this.state
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/statics/${this.state.staticId}.json?access_token=${this.props.access_token}`,
      data: { static: { name: state.name, description: state.description } },
      success: (data) => {
        if (data['static'].guild_slug === null) window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/statics`)
        else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data['static'].guild_slug}/management`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
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
      return <option value={guild.id} key={guild.id}>{guild.full_name}</option>
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

  render() {
    return (
      <div className="static_form">
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="static_name">{strings.name}</label>
            <input required="required" placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="static_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
          </div>
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="event_character_id">{strings.characterOwner}</label>
              <select className="form-control form-control-sm" id="event_character_id" onChange={this._onCharacterChange.bind(this)} value={this.state.currentCharacterId} disabled={this.state.staticId !== undefined || this.props.guild_id !== null}>
                <option value='0' key='0'></option>
                {this._renderUserCharacters()}
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="event_guild_id">{strings.guildOwner}</label>
              <select className="form-control form-control-sm" id="event_guild_id" onChange={this._onGuildChange.bind(this)} value={this.state.currentGuildId} disabled={this.state.staticId !== undefined || this.props.guild_id !== null}>
                <option value='0' key='0'></option>
                {this._renderUserGuilds()}
              </select>
            </div>
          </div>
        </div>
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="static_description">{strings.description}</label>
            <textarea placeholder={strings.description} className="form-control form-control-sm" type="text" id="static_description" value={this.state.description} onChange={(event) => this.setState({description: event.target.value})} />
          </div>
        </div>
        {this.state.staticId === undefined &&
          <input type="submit" name="commit" value={strings.create} className="btn btn-primary" onClick={this._onCreate.bind(this)} />
        }
        {this.state.staticId !== undefined &&
          <input type="submit" name="commit" value={strings.update} className="btn btn-primary" onClick={this._onUpdate.bind(this)} />
        }
      </div>
    )
  }
}
