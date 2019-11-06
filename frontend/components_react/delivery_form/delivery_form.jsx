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
      deliveryType: 0,
      deliveryParamId: '',
      deliveryParamToken: ''
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
        this.setState({notifications: data.notifications, notificationId: data.notifications[0].id})
      }
    })
  }

  _onCreate() {
    const state = this.state
    $.ajax({
      method: 'POST',
      url: `/api/v1/deliveries.json?access_token=${this.props.access_token}`,
      data: { delivery: { deliveriable_id: this.props.deliveriable_id, deliveriable_type: this.props.deliveriable_type, notification_id: state.notificationId, delivery_type: state.deliveryType }, delivery_param: { params: { id: state.deliveryParamId, token: state.deliveryParamToken } } },
      success: (data) => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/guilds/${data['delivery'].deliveriable.slug}/management`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
      }
    })
  }

  _onUpdate() {

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
    this.setState({deliveryType: event.target.value})
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
                <option value={0} key={0}>Discord webhook</option>
              </select>
            </div>
          </div>
          {this.state.deliveryType === 0 &&
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
          }
        </div>
        {this.state.deliveryId === undefined &&
          <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
        }
        {this.state.deliveryId !== undefined &&
          <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
        }
      </div>
    )
  }
}
