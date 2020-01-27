import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class ActivitiesList extends React.Component {
  constructor(props) {
    super(props)
    const date = new Date()
    this.state = {
      activities: [],
      subscribes: [],
      timeZoneOffsetMinutes: props.time_offset_value === null ? date.getTimezoneOffset() : - props.time_offset_value * 60,
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  componentDidMount() {
    this._getActivities()
  }

  _getActivities() {
    $.ajax({
      method: 'GET',
      url: `/api/v2/activities.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({activities: data.activities.data}, () => {
          this._getCloseEvents()
        })
      }
    })
  }

  _getCloseEvents() {
    $.ajax({
      method: 'GET',
      url: `/api/v2/subscribes/closest.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({subscribes: data.subscribes.data})
      }
    })
  }

  _renderActivities() {
    return this.state.activities.map((activity) => {
      const date = new Date(activity.attributes.updated_at * 1000)
      if (this.props.time_offset_value !== null) date.setHours(date.getHours() + this.props.time_offset_value + date.getTimezoneOffset() / 60)
      return (
        <div className="activity" key={activity.id}>
          <div className="title">{activity.attributes.title}</div>
          <div className="description">
            {activity.attributes.description}
            <div className="footer">
              {this._renderDate(date)}
              {activity.attributes.guild_name !== null && `, ${activity.attributes.guild_name}`}
            </div>
          </div>
        </div>
      )
    })
  }

  _renderDate(date) {
    return `${this._checkLessTen(date.getDate())}.${this._checkLessTen(date.getMonth() + 1)}.${date.getFullYear()} ${this._checkLessTen(date.getHours())}:${this._checkLessTen(date.getMinutes())}`
  }

  _renderSubscribeDate(date) {
    return `${this._checkLessTen(date.getDate())}.${this._checkLessTen(date.getMonth() + 1)} ${this._checkLessTen(date.getHours())}:${this._checkLessTen(date.getMinutes())}`
  }

  _checkLessTen(value) {
    if (value >= 10) return value
    return `0${value}`
  }

  _renderSubscribes() {
    return this.state.subscribes.map((subscribe) => {
      const date = new Date(subscribe.attributes.event.start_time * 1000)
      if (this.props.time_offset_value !== null) date.setHours(date.getHours() + this.props.time_offset_value + date.getTimezoneOffset() / 60)
      return (
        <div className="subscribe" key={subscribe.id}>
          <p>{this._renderSubscribeDate(date)}</p>
          <p><a href={`${this._checkLocale()}/events/${subscribe.attributes.event.slug}`}>{subscribe.attributes.event.name}</a></p>
          <p>{subscribe.attributes.character.name}</p>
          <span className={`status_icon small ${subscribe.attributes.status}`}></span>
        </div>
      )
    })
  }

  _checkLocale() {
    if (this.props.locale === "en") return ""
    return `/${this.props.locale}`
  }

  render() {
    return (
      <div className="activities">
        <div className="row">
          <div className="col-md-6 col-xl-4 last_guild_activities">
            {this._renderActivities()}
          </div>
          <div className="col-md-6 col-xl-4 close_events">
            {this._renderSubscribes()}
          </div>
        </div>
      </div>
    )
  }
}
