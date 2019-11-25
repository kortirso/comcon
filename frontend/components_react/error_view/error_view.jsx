import React from "react"

export default class ErrorView extends React.Component {
  _renderErrors() {
    if (typeof this.props.errors === 'string') return <p>{this.props.errors}</p>
    return this.props.errors.map((error, index) => {
      return <p key={index}>{error}</p>
    })
  }

  render() {
    return (
      <div className="flash-messages">
        <div className="alert alert-danger" role="alert">
          {this._renderErrors()}
        </div>
      </div>
    )
  }
}
