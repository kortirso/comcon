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
});

export default class UserPassword extends React.Component {
  constructor() {
    super()
    this.state = {
      password: '',
      passwordConfirmation: '',
      errors: [],
      alert: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _onSave() {
    let url = `/api/v1/user_settings/update_password.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: { user_settings: { password: this.state.password, password_confirmation: this.state.passwordConfirmation } },
      success: () => {
        this.setState({alert: strings.success, errors: [], password: '', passwordConfirmation: ''})
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors, alert: ''})
      }
    })
  }

  render() {
    return (
      <div>
        <div className="user_password">
          <h3>{strings.title}</h3>
          {this.state.errors.length > 0 &&
            <ErrorView errors={this.state.errors} />
          }
          {this.state.alert !== '' &&
            <Alert type="success" value={this.state.alert} />
          }
          <div className="form-group">
            <input className="form-control form-control-sm" type="password" placeholder={strings.password} value={this.state.password} onChange={(event) => this.setState({password: event.target.value})} />
            <p>{strings.minimum}</p>
            <input className="form-control form-control-sm" type="password" placeholder={strings.passwordConfirmation} value={this.state.passwordConfirmation} onChange={(event) => this.setState({passwordConfirmation: event.target.value})} />
          </div>
        </div>
        <div className="save_block">
          <input type="submit" name="commit" value={strings.save} className="btn btn-primary btn-sm" onClick={this._onSave.bind(this)} />
        </div>
      </div>
    )
  }
}
