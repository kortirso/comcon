import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class StaticsList extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      fractions: [],
      worlds: [],
      statics: [],
      fraction: '0',
      world: '0'
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getFractions()
  }

  componentDidMount() {
    this._getStatics()
  }

  _getFractions() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/fractions.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({fractions: data.fractions}, () => {
          this._getWorlds()
        })
      }
    })
  }

  _getWorlds() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/worlds.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({worlds: data.worlds})
      }
    })
  }

  _getStatics() {
    let params = []
    if (this.state.fraction !== '0') params.push(`fraction_id=${this.state.fraction}`)
    if (this.state.world !== '0') params.push(`world_id=${this.state.world}`)
    const url = `/api/v1/statics.json?access_token=${this.props.access_token}&` + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({statics: data.statics})
      }
    })
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderWorldFilter()}
        {this._renderFractionFilter()}
      </div>
    )
  }

  _renderWorldFilter() {
    return (
      <div className="filter world">
        <p>{strings.filterWorld}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeWorld.bind(this)} value={this.state.world}>
          <option value='0' key='0'>{strings.none}</option>
          {this._renderWorldsList()}
        </select>
      </div>
    )
  }

  _renderWorldsList() {
    return this.state.worlds.map((world) => {
      return <option value={world.id} key={world.id}>{world.name}</option>
    })
  }

  _renderFractionFilter() {
    return (
      <div className="filter fraction">
        <p>{strings.filterFraction}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeFraction.bind(this)} value={this.state.fraction}>
          <option value='0' key='0'>{strings.none}</option>
          {this._renderFractionsList()}
        </select>
      </div>
    )
  }

  _renderFractionsList() {
    return this.state.fractions.map((fraction) => {
      return <option value={fraction.id} key={fraction.id}>{fraction.name[this.props.locale]}</option>
    })
  }

  _renderStatics() {
    return this.state.statics.map((object) => {
      return (
        <tr className="static_link" onClick={this._goToStatic.bind(this, object.slug)} key={object.id}>
          <td className={object.fraction_name.en.toLowerCase()}>{object.name}</td>
          <td>{object.owner_name}</td>
          <td>{object.description}</td>
        </tr>
      )
    })
  }

  _onChangeWorld(event) {
    this.setState({world: event.target.value}, () => {
      this._getStatics()
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value}, () => {
      this._getStatics()
    })
  }

  _goToStatic(staticSlug) {
    window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/statics/${staticSlug}`
  }

  render() {
    return (
      <div className="statics">
        {this._renderFilters()}
        <table className="table table-striped table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.owner}</th>
              <th>{strings.description}</th>
            </tr>
          </thead>
          <tbody>
            {this._renderStatics()}
          </tbody>
        </table>
      </div>
    )
  }
}