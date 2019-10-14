import React from "react"

const $ = require("jquery")

export default class EventCalendar extends React.Component {
  constructor(props) {
    super(props)
    const date = new Date()
    this.state = {
      events: [],
      previousDaysAmount: (new Date(date.getFullYear(), date.getMonth(), 1)).getDay() - 1,
      daysAmount: (new Date(date.getFullYear(), date.getMonth() + 1, 0)).getDate(),
      currentYear: date.getFullYear(),
      currentMonth: date.getMonth() + 1
    }
  }

  componentWillMount() {
    this._getEvents()
  }

  _getEvents() {
    $.ajax({
      method: 'GET',
      url: '/events.json',
      success: (data) => {
        this.setState({events: data})
      }
    })
  }

  _renderPreviousMonth() {
    let days = []
    for (let i = 0; i < this.state.previousDaysAmount; i++) {
      days.push(
        <div className="day previous" key={i}>
          <div className="day_content"></div>
        </div>
      )
    }
    return days
  }

  _renderMonthDays() {
    let days = []
    for (let i = 0; i < this.state.daysAmount; i++) {
      days.push(
        <div className="day" key={i}>
          <div className="day_content">
            <div className="day_date">{i + 1}.{this.state.currentMonth}</div>
            {this._renderEvents(i + 1)}
          </div>
        </div>
      )
    }
    return days
  }

  _renderEvents(day) {
    const filtered = this.state.events.filter((event) => {
      return event.date == `${day}.${this.state.currentMonth}.${this.state.currentYear}`
    })
    return filtered.map((event) => {
      return (
        <a className="event" key={event.id} href={`/events/${event.slug}`}>
          <p className="name">{event.name}</p>
          <p className="time">{event.time}</p>
        </a>
      )
    })
  }

  render() {
    return (
      <div className="events">
        {this._renderPreviousMonth()}
        {this._renderMonthDays()}
      </div>
    )
  }
}
