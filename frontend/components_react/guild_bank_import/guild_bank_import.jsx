import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'
import Alert from '../alert/alert'

let strings = new LocalizedStrings(I18nData)

export default class GuildBankImport extends React.Component {
  constructor() {
    super()
    this.state = {
      showModal: false,
      errors: [],
      alert: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  render() {
    return (
      <div>
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        {this.state.alert !== '' &&
          <Alert type="success" value={this.state.alert} />
        }
        <button className="btn btn-primary btn-sm" onClick={() => this.setState({showModal: true})}>{strings.import_button}</button>
        <div className={`modal fade ${this.state.showModal ? 'show' : ''}`} id="guild_data_import" tabIndex="-1" role="dialog" aria-labelledby="guild_data_import_label" aria-hidden="true" onClick={() => this.setState({showModal: false})}>
          <div className="modal-dialog" role="document" onClick={(e) => { e.stopPropagation() }}>
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title" id="guild_data_import_label">{strings.title}</h5>
                <button type="button" className="close" onClick={() => this.setState({showModal: false})}>
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div className="modal-body">
                <textarea className="form-control from-control-sm" placeholder={strings.placeholder} />
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-primary btn-sm" onClick={() => console.log(1)}>{strings.import}</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
