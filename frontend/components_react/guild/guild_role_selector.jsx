import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class GuildRoleSelector extends React.Component {
  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _onChangeGuildRole(event) {
    this.props.onChangeGuildRole(this.props.character.id, event.target.value)
  }

  render() {
    return (
      <select className="form-control form-control-sm" onChange={this._onChangeGuildRole.bind(this)} value={this.props.character.guild_role !== null ? this.props.character.guild_role.name : '0'}>
        <option value='0' key='0'>{strings.none}</option>
        {(this.props.isAdmin || this.props.isGm) &&
          <option value='gm' key='1'>{strings.gm}</option>
        }
        <option value='rl' key='2'>{strings.rl}</option>
        <option value='cl' key='3'>{strings.cl}</option>
      </select>
    )
  }
}
