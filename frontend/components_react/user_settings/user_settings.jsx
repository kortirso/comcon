import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class UserSettings extends React.Component {
  constructor() {
    super()
    this.state = {
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  render() {
    return (
      <div className="user_settings">
        <h2>{strings.personal}</h2>
        <h3>{strings.timeZone}</h3>
      </div>
    )
  }
}
