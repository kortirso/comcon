import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class StaticsList extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      fractions: [],
      worlds: [],
      statics: [],
      filteredStatics: [],
      fraction: '0',
      world: '0',
      characters: [],
      character: '0',
      staticsForCharacter: []
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
        this.setState({worlds: data.worlds}, () => {
          this._getUserCharacters()
        })
      }
    })
  }

  _getUserCharacters() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({characters: data.characters})
      }
    })
  }

  _getStatics() {
    const url = `/api/v1/statics.json?access_token=${this.props.access_token}`
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({statics: data.statics}, () => {
          this._filterStatics()
        })
      }
    })
  }

  _getStaticsForCharacter() {
    const url = `/api/v1/statics.json?access_token=${this.props.access_token}&character_id=${this.state.character}&world_id=${this.state.world}&fraction_id=${this.state.fraction}`
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({staticsForCharacter: data.statics})
      }
    })
  }

  _filterStatics() {
    const state = this.state
    let filters = {}
    if (state.fraction !== '0') filters['fraction_id'] = parseInt(state.fraction)
    if (state.world !== '0') filters['world_id'] = parseInt(state.world)
    const statics = state.statics.filter(function(object) {
      for (var key in filters) {
        if (object[key] === undefined || object[key] != filters[key]) return false
      }
      return true
    })
    this.setState({filteredStatics: statics})
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderWorldFilter()}
        {this._renderFractionFilter()}
        {this._renderCharacterFilter()}
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

  _renderCharacterFilter() {
    return (
      <div className="filter character">
        <p>{strings.filterCharacter}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeCharacter.bind(this)} value={this.state.character}>
          <option value='0' key='0'>{strings.none}</option>
          {this._renderCharactersList()}
        </select>
      </div>
    )
  }

  _renderCharactersList() {
    return this.state.characters.map((character) => {
      return <option value={character.id} key={character.id}>{character.name}</option>
    })
  }

  _renderAllStatics() {
    const statics = this.state.character === '0' ? this.state.filteredStatics : this.state.staticsForCharacter
    if (statics.length === 0) return <p>{strings.noStatics}</p>
    return (
      <table className="table table-striped table-sm">
        <thead>
          <tr>
            <th>{strings.name}</th>
            <th>{strings.owner}</th>
            <th>{strings.description}</th>
            <th>{strings.leftValues}</th>
          </tr>
        </thead>
        <tbody>
          {this._renderStatics(statics)}
        </tbody>
      </table>
    )
  }

  _renderStatics(statics) {
    return statics.map((object) => {
      return (
        <tr className="static_link" onClick={this._goToStatic.bind(this, object.slug)} key={object.id}>
          <td className={object.fraction_name.en.toLowerCase()}>{object.name}</td>
          <td>{object.owner_name}</td>
          <td>{object.description}</td>
          <td>{this._renderLeftValues(object)}</td>
        </tr>
      )
    })
  }

  _renderLeftValues(object) {
    if (object.left_value === null) return false
    return ["tanks", "healers", "dd"].map((role) => {
      const result = Object.entries(object.left_value[role].by_class).filter(([key, value]) => {
        return value > 0
      })
      return this._renderLeftRoles(result, role)
    })
  }

  _renderLeftRoles(values, role) {
    return values.map((value, index) => {
      return (
        <span className={`left_value class_icon ${value[0]}`} key={index}>
          <span className={`role ${role}`}></span>
          <span className="amount">{value[1]}</span>
        </span>
      )
    })
  }

  _onChangeWorld(event) {
    this.setState({world: event.target.value, character: '0'}, () => {
      this._filterStatics()
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value, character: '0'}, () => {
      this._filterStatics()
    })
  }

  _onChangeCharacter(event) {
    if (event.target.value === '0') {
      this.setState({character: '0', staticsForCharacter: []}, () => {
        this._filterStatics()
      })
    } else {
      const character = this.state.characters.filter((character) => {
        return character.id === parseInt(event.target.value)
      })[0]
      this.setState({character: event.target.value, world: character.world_id, fraction: character.fraction_id}, () => {
        this._getStaticsForCharacter()
      })
    }
  }

  _goToStatic(staticSlug) {
    window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/statics/${staticSlug}`
  }

  render() {
    return (
      <div className="statics">
        {this._renderFilters()}
        {this._renderAllStatics()}
      </div>
    )
  }
}
