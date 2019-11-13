import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class DeliveryForm extends React.Component {
  constructor() {
    super()
    this.state = {
      notifications: [],
      notificationId: '0',
      deliveryType: 2,
      deliveryParamId: '',
      deliveryParamToken: '',
      deliveryParamChannelId: ''
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
    $.ajax({
      method: 'POST',
      url: `/api/v1/deliveries.json?access_token=${this.props.access_token}`,
      data: { delivery: { deliveriable_id: this.props.deliveriable_id, deliveriable_type: this.props.deliveriable_type, notification_id: state.notificationId, delivery_type: state.deliveryType }, delivery_param: { params: params } },
      success: (data) => {
        if (data.delivery.deliveriable !== null) window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data.delivery.deliveriable.slug}/management`)
        else window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/settings/notifications`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
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
    this.setState({notificationId: event.target.value})
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
      <div className="double_line">
        <div className="form-group">
          <label htmlFor="delivery_param_id">{strings.webhookId}</label>
          <input placeholder={strings.webhookId} className="form-control form-control-sm" type="text" id="delivery_param_id" value={this.state.deliveryParamId} onChange={(event) => this.setState({deliveryParamId: event.target.value})} />
        </div>
        <div className="form-group">
          <label htmlFor="delivery_param_token">{strings.webhookToken}</label>
          <input placeholder={strings.webhookToken} className="form-control form-control-sm" type="text" id="delivery_param_token" value={this.state.deliveryParamToken} onChange={(event) => this.setState({deliveryParamToken: event.target.value})} />
        </div>
      </div>
    )
  }

  _renderDiscordMessageParams() {
    return (
      <div className="double_line">
        <div className="form-group">
          <label htmlFor="delivery_param_channel_id">{strings.channelId}</label>
          <input placeholder={strings.channelId} className="form-control form-control-sm" type="text" id="delivery_param_channel_id" value={this.state.deliveryParamChannelId} onChange={(event) => this.setState({deliveryParamChannelId: event.target.value})} />
        </div>
      </div>
    )
  }

  render() {
    return (
      <div className="delivery_form">
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="delivery_notification_id">{strings.notification}</label>
              <select className="form-control form-control-sm" id="delivery_notification_id" onChange={this._onNotificationChange.bind(this)} value={this.state.notificationId}>
                {this._renderNotifications()}
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="delivery_type">{strings.deliveryType}</label>
              <select className="form-control form-control-sm" id="delivery_type" onChange={this._onDeliveryTypeChange.bind(this)} value={this.state.deliveryType}>
                {this.props.deliveriable_type === 'Guild' &&
                  <option value={0} key={0}>Discord webhook</option>
                }
                <option value={1} key={1}>Discord message</option>
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
