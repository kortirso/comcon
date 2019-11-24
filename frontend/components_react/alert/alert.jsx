import React from "react"

export default class Alert extends React.Component {
  render() {
    return (
      <div className="row">
        <div className="col-md-6">
          <div className={`alert alert-${this.props.type}`} role="alert">
            {this.props.value}
          </div>
        </div>
      </div>
    )
  }
}
