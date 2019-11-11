import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import 'air-datepicker/dist/js/datepicker.js'
import 'air-datepicker/dist/js/i18n/datepicker.en.js'

import ErrorView from '../error_view/error_view'

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class EventForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      name: '',
      creatorId: '',
      userCharacters: [],
      eventableType: 'Guild',
      eventType: 'instance',
      dungeons: [],
      currentDungeons: [],
      dungeonId: '',
      description: '',
      startTime: 0,
      hoursBeforeClose: 0,
      eventId: props.event_id,
      statics: [],
      currentStatics: [],
      staticId: '',
      errors: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getDefaultValues()
  }

  componentDidMount() {
    const _this = this
    $(".datepicker-here").datepicker({
      minDate: new Date(),
      onSelect: function(formattedDate, date) {
        _this.setState({startTime: Number(date) / 1000})
      }
    })

    const currentDate = new Date()
    $(".datepicker-here").data('datepicker').selectDate(new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate(), currentDate.getHours(), currentDate.getMinutes()))
  }

  _getDefaultValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/event_form_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const currentDungeons = this._selectDungeons(data.dungeons)
        const currentStatics = data.statics.filter((staticItem) => {
          return staticItem.characters.includes(data.characters[0].id)
        })
        this.setState({userCharacters: data.characters, creatorId: data.characters[0].id, dungeons: data.dungeons, currentDungeons: currentDungeons, dungeonId: (currentDungeons.length === 0 ? '' : currentDungeons[0].id), statics: data.statics, currentStatics: currentStatics}, () => {
          this._getEvent()
        })
      }
    })
  }

  _getEvent() {
    if (this.state.eventId === undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/events/${this.state.eventId}/edit.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const event = data.event
        let dates = event.date.split('.').map((time) => {
          return parseInt(time)
        })
        const currentDate = new Date()
        const timeZoneOffset = currentDate.getTimezoneOffset() / 60
        const startTime = new Date(dates[2], dates[1] - 1, dates[0], event.time.hours - timeZoneOffset, event.time.minutes)
        $(".datepicker-here").data('datepicker').selectDate(startTime)
        const currentStatics = this.state.statics.filter((staticItem) => {
          return staticItem.characters.includes(event.owner_id)
        })
        let eventableType = event.eventable_type
        let staticId
        if (eventableType === 'Static') {
          if (currentStatics.length === 0) {
            staticId = ''
            eventableType = 'World'
          } else {
            staticId = currentStatics[0].id
          }
        }
        this.setState({name: event.name, description: event.description, creatorId: event.owner_id, dungeonId: (event.dungeon_id === null ? '' : event.dungeon_id), eventType: event.event_type, eventableType: eventableType, startTime: Number(startTime) / 1000, staticId: staticId, currentStatics: currentStatics})
      }
    })
  }

  _onCreate() {
    const state = this.state
    let data = { event: { name: state.name, owner_id: state.creatorId, eventable_type: state.eventableType, hours_before_close: (state.hoursBeforeClose ? parseInt(state.hoursBeforeClose) : 0), dungeon_id: state.dungeonId, start_time: state.startTime, description: state.description } }
    if (state.eventableType === 'Static') data.event.eventable_id = state.staticId
    let url = `/api/v1/events.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: data,
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/events`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let data = { event: { name: state.name, owner_id: state.creatorId, eventable_type: state.eventableType, hours_before_close: (state.hoursBeforeClose ? parseInt(state.hoursBeforeClose) : 0), dungeon_id: state.dungeonId, start_time: state.startTime, description: state.description } }
    if (state.eventableType === 'Static') data.event.eventable_id = state.staticId
    let url = `/api/v1/events/${state.eventId}.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: data,
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/events`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _renderUserCharacters() {
    return this.state.userCharacters.map((character) => {
      return <option value={character.id} key={character.id}>{character.name}</option>
    })
  }

  _renderStatics() {
    return this.state.currentStatics.map((staticItem) => {
      return <option value={staticItem.id} key={staticItem.id}>{staticItem.name}</option>
    })
  }

  _renderDungeons() {
    return this.state.currentDungeons.map((dungeon) => {
      return <option value={dungeon.id} key={dungeon.id}>{dungeon.name[this.props.locale]}</option>
    })
  }

  _renderSubmitButton() {
    if (this.state.eventId === undefined) return <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
    return <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
  }

  _onChangeEventType(event) {
    this.setState({eventType: event.target.value}, () => {
      const currentDungeons = this._selectDungeons(this.state.dungeons)
      this.setState({currentDungeons: currentDungeons, dungeonId: (currentDungeons.length === 0 ? '' : currentDungeons[0].id)})
    })
  }

  _selectDungeons(dungeonsList) {
    let currentDungeons = []
    if (this.state.eventType === 'instance') {
      currentDungeons = dungeonsList.filter((dungeon) => {
        return !dungeon.raid
      })
    } else if (this.state.eventType === 'raid') {
      currentDungeons = dungeonsList.filter((dungeon) => {
        return dungeon.raid
      })
    }
    return currentDungeons
  }

  _onChangeCreator(event) {
    const creatorId = parseInt(event.target.value)
    const currentStatics = this.state.statics.filter((staticItem) => {
      return staticItem.characters.includes(creatorId)
    })
    let eventableType = this.state.eventableType
    let staticId
    if (eventableType === 'Static') {
      if (currentStatics.length === 0) {
        staticId = ''
        eventableType = 'World'
      } else {
        staticId = currentStatics[0].id
      }
    }
    this.setState({creatorId: event.target.value, currentStatics: currentStatics, staticId: staticId, eventableType: eventableType})
  }

  _onChangeEventableType(event) {
    this.setState({eventableType: event.target.value})
  }

  render() {
    return (
      <div className="character_form">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="event_name">{strings.name}</label>
              <input required="required" placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="event_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
            </div>
            <div className="form-group">
              <label htmlFor="event_owner_id">{strings.creator}</label>
              <select className="form-control form-control-sm" id="event_owner_id" onChange={this._onChangeCreator.bind(this)} value={this.state.creatorId} disabled={this.state.eventId !== undefined}>
                {this._renderUserCharacters()}
              </select>
            </div>
          </div>
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="event_start_time">{strings.startTime}</label>
              <input type="text" className="datepicker-here form-control form-control-sm" id="event_start_time" data-language={this.props.locale} data-date-format="dd.mm.yyyy" data-timepicker="true" />
            </div>
            <div className="form-group">
              <label htmlFor="event_hours_before_close">{strings.hoursBeforeClose}</label>
              <input placeholder={strings.hoursBeforeClose} className="form-control form-control-sm" type="text" onChange={(event) => this.setState({hoursBeforeClose: event.target.value})} value={this.state.hoursBeforeClose} id="event_hours_before_close" />
            </div>
          </div>
        </div>
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="event_eventable_type">{strings.eventableType}</label>
              <select className="form-control form-control-sm" id="event_eventable_type" onChange={this._onChangeEventableType.bind(this)} value={this.state.eventableType} disabled={this.state.eventId !== undefined}>
                <option value='Guild' key='Guild'>{strings.guild}</option>
                <option value='World' key='World'>{strings.world}</option>
                {this.state.currentStatics.length > 0 &&
                  <option value='Static' key='Static'>{strings.staticLabel}</option>
                }
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="event_static_id">{strings.statics}</label>
              <select className="form-control form-control-sm" id="event_static_id" onChange={(event) => this.setState({staticId: event.target.value})} value={this.state.staticId} disabled={this.state.eventableType !== 'Static' || this.state.eventId !== undefined}>
                {this.state.eventableType !== 'Static' &&
                  <option value='' key={0}></option>
                }
                {this._renderStatics()}
              </select>
            </div>
          </div>
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="event_type">{strings.eventType}</label>
              <select className="form-control form-control-sm" id="event_type" onChange={this._onChangeEventType.bind(this)} value={this.state.eventType}>
                <option value='instance' key='instance'>{strings.instance}</option>
                <option value='raid' key='raid'>{strings.raid}</option>
                <option value='custom' key='custom'>{strings.custom}</option>
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="event_dungeon_id">{strings.eventTarget}</label>
              <select className="form-control form-control-sm" id="event_dungeon_id" onChange={(event) => this.setState({dungeonId: event.target.value})} value={this.state.dungeonId}>
                {this._renderDungeons()}
              </select>
            </div>
          </div>
        </div>
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="event_description">{strings.description}</label>
            <textarea placeholder={strings.description} className="form-control form-control-sm" type="text" id="event_description" value={this.state.description} onChange={(event) => this.setState({description: event.target.value})} />
          </div>
        </div>
        {this._renderSubmitButton()}
      </div>
    )
  }
}
