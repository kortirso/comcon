import React from "react"

export default class Alert extends React.Component {
  render() {
    return (
      <div className="flash-messages">
        <div className={`alert alert-${this.props.type}`} role="alert">
          {this.props.value}
        </div>
      </div>
    )
  }
}
