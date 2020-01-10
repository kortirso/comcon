import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import Alert from '../alert/alert'

let strings = new LocalizedStrings(I18nData)

export default class CharacterEquipmentImport extends React.Component {
  constructor() {
    super()
    this.state = {
      showModal: false,
      data: '',
      alert: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _importData() {
    $.ajax({
      method: 'POST',
      url: `/api/v2/characters/${this.props.character_id}/equipment.json?access_token=${this.props.access_token}`,
      data: { value: this.state.data }
    })
    this.setState({showModal: false, alert: strings.importResult})
  }

  render() {
    return (
      <div>
        {this.state.alert !== '' &&
          <Alert type="success" value={this.state.alert} />
        }
        <button className="btn btn-primary btn-sm" onClick={() => this.setState({showModal: true})}>{strings.importButton}</button>
        <div className={`modal fade ${this.state.showModal ? 'show' : ''}`} id="character_equipment_import" tabIndex="-1" role="dialog" aria-labelledby="character_equipment_import_label" aria-hidden="true" onClick={() => this.setState({showModal: false})}>
          <div className="modal-dialog" role="document" onClick={(e) => { e.stopPropagation() }}>
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title" id="character_equipment_import_label">{strings.title}</h5>
                <button type="button" className="close" onClick={() => this.setState({showModal: false})}>
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div className="modal-body">
                <p>{strings.link_1} <a href="/files/ProfScanner.zip" download="/files/ProfScanner.zip">ProfScanner</a> {strings.link_2}</p>
                <textarea className="form-control from-control-sm" placeholder={strings.placeholder} value={this.state.data} onChange={(event) => this.setState({data: event.target.value})} />
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-primary btn-sm" onClick={() => this._importData()}>{strings.import}</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
