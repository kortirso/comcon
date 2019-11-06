import React from "react"

export default class ErrorView extends React.Component {
  _renderErrors() {
    return this.props.errors.map((error, index) => {
      return <p key={index}>{error}</p>
    })
  }

  render() {
    return (
      <div className="alert alert-danger" role="alert">
        {this._renderErrors()}
      </div>
    )
  }
}
