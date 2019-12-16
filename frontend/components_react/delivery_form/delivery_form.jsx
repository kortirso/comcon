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

export default class DeliveryForm extends React.Component {
  constructor() {
    super()
    this.state = {
      notifications: [],
      notificationId: '0',
      deliveryType: 2,
      deliveryParamId: '',
      deliveryParamToken: '',
      deliveryParamChannelId: '',
      errors: [],
      guildRequestCreation: false
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getDefaultValues()
  }

  _getDefaultValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/notifications.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const notifications = data.notifications.filter((notification) => {
          return (notification.status === 'guild' && this.props.deliveriable_type === 'Guild') || (notification.status === 'user' && this.props.deliveriable_type === 'User')
        })
        this.setState({notifications: notifications, notificationId: notifications.length > 0 ? notifications[0].id : '0'})
      }
    })
  }

  _onCreate() {
    const state = this.state
    const params = this._defineParams()
    let url = `/api/v1/deliveries.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { delivery: { deliveriable_id: this.props.deliveriable_id, deliveriable_type: this.props.deliveriable_type, notification_id: state.notificationId, delivery_type: state.deliveryType }, delivery_param: { params: params } },
      success: (data) => {
        if (data.delivery.deliveriable !== null) window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data.delivery.deliveriable.slug}/notifications`)
        else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/settings/notifications`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _defineParams() {
    const state = this.state
    if (this.state.deliveryType === 0) return { id: state.deliveryParamId, token: state.deliveryParamToken }
    else if (this.state.deliveryType === 2) {
      if (this.props.deliveriable_type === 'Guild') return { channel_id: state.deliveryParamChannelId }
      else if (this.props.deliveriable_type === 'User') return { channel_id: '' }
      else return {}
    } else return {}
  }

  _renderNotifications() {
    return this.state.notifications.map((notification) => {
      return <option value={notification.id} key={notification.id}>{notification.name[this.props.locale]}</option>
    })
  }

  _onNotificationChange(event) {
    const notification = this.state.notifications.filter((notification) => {
      return notification.id === parseInt(event.target.value)
    })[0]
    if (notification.event === "guild_request_creation" || notification.event === "bank_request_creation") {
      this.setState({notificationId: event.target.value, deliveryType: 2, guildRequestCreation: true})
    } else this.setState({notificationId: event.target.value, guildRequestCreation: false})
  }

  _onDeliveryTypeChange(event) {
    this.setState({deliveryType: parseInt(event.target.value)})
  }

  _renderDeliveryParams() {
    if (this.state.notifications.length === 0) return false
    if (this.state.deliveryType === 0) return this._renderDiscordWebhookParams()
    else if (this.props.deliveriable_type === 'Guild' && this.state.deliveryType === 2) return this._renderDiscordMessageParams()
    else return false
  }

  _renderDiscordWebhookParams() {
    return (
      <div className="col-md-6">
        <div className="row">
          <div className="col-md-6">
            <div className="form-group">
              <label htmlFor="delivery_param_id">{strings.webhookId}</label>
              <input placeholder={strings.webhookId} className="form-control form-control-sm" type="text" id="delivery_param_id" value={this.state.deliveryParamId} onChange={(event) => this.setState({deliveryParamId: event.target.value})} />
            </div>
          </div>
          <div className="col-md-6">
            <div className="form-group">
              <label htmlFor="delivery_param_token">{strings.webhookToken}</label>
              <input placeholder={strings.webhookToken} className="form-control form-control-sm" type="text" id="delivery_param_token" value={this.state.deliveryParamToken} onChange={(event) => this.setState({deliveryParamToken: event.target.value})} />
            </div>
          </div>
        </div>
      </div>
    )
  }

  _renderDiscordMessageParams() {
    return (
      <div className="col-md-6 col-lg-3">
        <div className="form-group">
          <label htmlFor="delivery_param_channel_id">{strings.channelId}</label>
          <input placeholder={strings.channelId} className="form-control form-control-sm" type="text" id="delivery_param_channel_id" value={this.state.deliveryParamChannelId} onChange={(event) => this.setState({deliveryParamChannelId: event.target.value})} disabled={this.state.guildRequestCreation} />
        </div>
      </div>
    )
  }

  render() {
    return (
      <div className="delivery_form">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="row">
          <div className="col-md-6 col-lg-3">
            <div className="form-group">
              <label htmlFor="delivery_notification_id">{strings.notification}</label>
              <select className="form-control form-control-sm" id="delivery_notification_id" onChange={this._onNotificationChange.bind(this)} value={this.state.notificationId}>
                {this._renderNotifications()}
              </select>
            </div>
          </div>
          <div className="col-md-6 col-lg-3">
            <div className="form-group">
              <label htmlFor="delivery_type">{strings.deliveryType}</label>
              <select className="form-control form-control-sm" id="delivery_type" onChange={this._onDeliveryTypeChange.bind(this)} value={this.state.deliveryType} disabled={this.state.guildRequestCreation}>
                {this.props.deliveriable_type === 'Guild' &&
                  <option value={0} key={0}>Discord webhook</option>
                }
                <option value={2} key={2}>Discord message</option>
              </select>
            </div>
          </div>
          {this._renderDeliveryParams()}
        </div>
        <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
      </div>
    )
  }
}
