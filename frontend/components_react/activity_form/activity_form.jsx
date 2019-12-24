import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class ActivityForm extends React.Component {
  constructor() {
    super()
    this.state = {
      title: '',
      description: '',
      errors: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _onCreate() {
    const state = this.state
    let url = `/api/v2/activities.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { activity: { title: state.title, description: state.description, guild_id: this.props.guild_id } },
      success: (data) => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${this.props.guild_slug}/activities`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _renderSubmitButton() {
    return <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
  }

  render() {
    return (
      <div className="activity_form">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="row">
          <div className="col-md-6">
            <div className="form-group">
              <label htmlFor="activity_title">{strings.title}</label>
              <input required="required" placeholder={strings.title} className="form-control form-control-sm" type="text" id="activity_title" value={this.state.title} onChange={(event) => this.setState({title: event.target.value})} />
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col-md-6">
            <div className="form-group">
              <label htmlFor="activity_description">{strings.description}</label>
              <textarea placeholder={strings.description} className="form-control form-control-sm" type="text" id="activity_description" value={this.state.description} onChange={(event) => this.setState({description: event.target.value})} />
            </div>
          </div>
        </div>
        {this._renderSubmitButton()}
      </div>
    )
  }
}
