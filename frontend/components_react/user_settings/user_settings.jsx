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
      timeOffset: { id: null, value: '' }
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getUserSettings()
  }

  _getUserSettings() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/user_settings.json?access_token=${this.props.access_token}`,
      success: (data) => {
        let timeOffset = data.time_offset
        if (timeOffset.value === null) timeOffset.value = ''
        this.setState({timeOffset: timeOffset})
      }
    })
  }

  _onSave() {
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/user_settings/update_settings.json?access_token=${this.props.access_token}`,
      data: { user_settings: { time_offset: this.state.timeOffset } },
      success: (data) => {
      },
      error: () => {
        console.log('Error')
      }
    })
  }

  _renderTimeOffsets() {
    let timeOffsets = []
    for (let i = -12; i < 13; i++) {
      timeOffsets.push(<option value={i} key={i}>GMT {i > 0 ? `+${i}` : i}</option>)
    }
    return timeOffsets
  }

  _onChangeTimeOffset(event) {
    let timeOffset = this.state.timeOffset
    timeOffset.value = event.target.value
    this.setState({timeOffset: timeOffset})
  }

  render() {
    return (
      <div>
        <div className="user_settings">
          <h2>{strings.personal}</h2>
          <div className="settings_block">
            <h3>{strings.timeZone}</h3>
            <select className="form-control form-control-sm time_offset" id="event_character_id" onChange={this._onChangeTimeOffset.bind(this)} value={this.state.timeOffset.value}>
              <option value='' key='20'>{strings.browser}</option>
              {this._renderTimeOffsets()}
            </select>
          </div>
        </div>
        <div className="save_block">
          <input type="submit" name="commit" value={strings.save} className="btn btn-primary btn-sm" onClick={this._onSave.bind(this)} />
        </div>
      </div>
    )
  }
}
