import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

const monthes = [
  { en: 'January', ru: 'Январь' },
  { en: 'February', ru: 'Февраль' },
  { en: 'March', ru: 'Март' },
  { en: 'April', ru: 'Апрель' },
  { en: 'May', ru: 'Май' },
  { en: 'June', ru: 'Июнь' },
  { en: 'July', ru: 'Июль' },
  { en: 'August', ru: 'Август' },
  { en: 'September', ru: 'Сентябрь' },
  { en: 'October', ru: 'Октябрь' },
  { en: 'November', ru: 'Ноябрь' },
  { en: 'December', ru: 'Декабрь' }
]

let strings = new LocalizedStrings(I18nData)

export default class TimeSelector extends React.Component {
  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _renderDays() {
    let result = []
    for (let i = 1; i < 32; i++) {
      result.push(<option value={i} key={i}>{i < 10 ? `0${i}` : i}</option>)
    }
    return result
  }

  _renderMonthes() {
    let result = []
    for (let i = 0; i < 12; i++) {
      result.push(<option value={i + 1} key={i}>{monthes[i][this.props.locale]}</option>)
    }
    return result
  }

  _renderYears() {
    let result = []
    result.push(<option value="2019" key={2019}>2019</option>)
    result.push(<option value="2020" key={2020}>2020</option>)
    return result
  }

  renderHours() {
    let result = []
    for (let i = 0; i < 24; i++) {
      result.push(<option value={i} key={i}>{i < 10 ? `0${i}` : i}</option>)
    }
    return result
  }

  renderMinutes() {
    let result = []
    for (let i = 0; i < 60; i++) {
      result.push(<option value={i} key={i}>{i < 10 ? `0${i}` : i}</option>)
    }
    return result
  }

  _onChange(index, event) {
    this.props.onChangeStartTime(index, event.target.value)
  }

  render() {
    return (
      <div className="time_selector">
        <select id="days" className="form-control form-control-sm" value={this.props.startTime[0]} onChange={this._onChange.bind(this, 0)}>
          {this._renderDays()}
        </select>
        <select id="monthes" className="form-control form-control-sm" value={this.props.startTime[1]} onChange={this._onChange.bind(this, 1)}>
          {this._renderMonthes()}
        </select>
        <select id="years" className="form-control form-control-sm" value={this.props.startTime[2]} onChange={this._onChange.bind(this, 2)}>
          {this._renderYears()}
        </select>
        <select id="hours" className="form-control form-control-sm" value={this.props.startTime[3]} onChange={this._onChange.bind(this, 3)}>
          {this.renderHours()}
        </select>
        <select id="minutes" className="form-control form-control-sm" value={this.props.startTime[4]} onChange={this._onChange.bind(this, 4)}>
          {this.renderMinutes()}
        </select>
      </div>
    )
  }
}
