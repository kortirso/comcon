import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
})

export default class CharacterTransferForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      data: {},
      name: '',
      worlds: [],
      characterClasses: [],
      roles: {},
      races: {},
      secondaryRoles: [],
      currentRace: null,
      currentCharacterClass: null,
      currentWorld: 0,
      currentMainRole: null,
      currentSecondaryRoles: {},
      characterId: props.character_id,
      currentFractionId: 0,
      updateFractionId: 0,
      errors: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  componentDidMount() {
    this._getDefaultValues()
  }

  _getDefaultValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/default_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const currentRace = Object.keys(data.races)[0]
        const currentFractionId = data.races[currentRace].fraction_id
        const currentCharacterClass = Object.keys(data.character_classes)[0]
        const roles = data.character_classes[currentCharacterClass].roles
        const currentMainRole = Object.keys(roles)[0]

        this.setState({worlds: data.worlds, races: data.races, characterClasses: data.character_classes, currentMainRole: currentMainRole, currentFractionId: currentFractionId, updateFractionId: currentFractionId}, () => {
          this._getCharacter()
        })
      }
    })
  }

  _getCharacter() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/${this.state.characterId}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const character = data.character
        const currentCharacterClass = character.character_class_id.toString()
        const roles = this.state.characterClasses[currentCharacterClass].roles
        const currentMainRole = character.main_role_id.toString()

        const secondaryRoles = Object.entries(roles).filter(([key, value]) => {
          return key !== currentMainRole
        })
        let currentSecondaryRoles = {}
        secondaryRoles.forEach((role) => {
          currentSecondaryRoles[role[0]] = (character.secondary_role_ids.includes(parseInt(role[0])) ? 1 : 0)
        })
        const secNames = secondaryRoles.map((role) => {
          return ({
            id: role[0],
            name: role[1].name
          })
        })

        this.setState({name: character.name, level: character.level, currentRace: character.race_id, currentCharacterClass: currentCharacterClass, roles: roles, currentMainRole: currentMainRole, currentWorld: character.world_id, secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let currentSecondaryRoles = state.currentSecondaryRoles
    currentSecondaryRoles[state.currentMainRole] = '1'
    let url = `/api/v2/characters/${state.characterId}/transfer.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: { character: { name: state.name, race_id: state.currentRace, character_class_id: state.currentCharacterClass, world_id: state.currentWorld, main_role_id: state.currentMainRole, roles: currentSecondaryRoles } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _renderRaces() {
    return Object.entries(this.state.races).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _renderRaceCharacterClasses() {
    return Object.entries(this.state.characterClasses).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _renderWorlds() {
    return this.state.worlds.map((world) => {
      return <option value={world.id} key={world.id}>{world.name}</option>
    })
  }

  _renderClassRoles() {
    const race = this.state.races[this.state.currentRace]
    if (race === undefined) return false
    const characterClass = this.state.characterClasses[this.state.currentCharacterClass]
    if (characterClass === undefined) return false

    return Object.entries(characterClass.roles).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _renderSecondaryRoles() {
    return this.state.secondaryRoles.map((role) => {
      return (
        <div className="form-group form-check" key={role.id}>
          <input className="form-check-input" type="checkbox" checked={this.state.currentSecondaryRoles[role.id] === 1} onChange={this._onChangeRole.bind(this, role.id)} id={`character_roles[${role.id}]`} />
          <label htmlFor={`character_roles[${role.id}]`}>{role.name[this.props.locale]}</label>
        </div>
      )
    })
  }

  _onChangeRace(event) {
    const currentRace = event.target.value
    const updateFractionId = this.state.races[currentRace].fraction_id
    this.setState({currentRace: currentRace, updateFractionId: updateFractionId})
  }

  _onChangeClass(event) {
    const currentCharacterClass = event.target === undefined ? event : event.target.value
    const roles = this.state.characterClasses[currentCharacterClass].roles
    const currentMainRole = Object.keys(roles)[0]

    this.setState({currentCharacterClass: currentCharacterClass, roles: roles}, () => {
      this._onChangeMainRole(currentMainRole)
    })
  }

  _onChangeMainRole(event) {
    const currentMainRole = event.target === undefined ? event : event.target.value
    const secondaryRoles = Object.entries(this.state.roles).filter(([key, value]) => {
      return key !== currentMainRole
    })
    let currentSecondaryRoles = {}
    secondaryRoles.forEach((role) => {
      currentSecondaryRoles[role[0]] = 0
    })
    const secNames = secondaryRoles.map((role) => {
      return ({
        id: role[0],
        name: role[1].name
      })
    })
    this.setState({currentMainRole: currentMainRole, secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
  }

  _onChangeWorld(event) {
    this.setState({currentWorld: event.target.value})
  }

  _onChangeRole(roleId) {
    let roles = this.state.currentSecondaryRoles
    roles[roleId] = (roles[roleId] === 0 ? 1 : 0)
    this.setState({currentSecondaryRoles: roles})
  }

  render() {
    return (
      <div className="character_form">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="row">
          <div className="col-xl-6">
            <p>{strings.warning}</p>
            <div className="row">
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_name">{strings.name}</label>
                  <input required="required" placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="character_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
                </div>
              </div>
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="world_id">{strings.world}</label>
                  <select className="form-control form-control-sm" id="world_id" onChange={this._onChangeWorld.bind(this)} value={this.state.currentWorld}>
                    {this._renderWorlds()}
                  </select>
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_race_id">{strings.race}</label>
                  <select className="form-control form-control-sm" id="character_race_id" onChange={this._onChangeRace.bind(this)} value={this.state.currentRace === null ? '0' : this.state.currentRace}>
                    {this._renderRaces()}
                  </select>
                </div>
              </div>
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_character_class_id">{strings.characterClass}</label>
                  <select className="form-control form-control-sm" id="character_character_class_id" onChange={this._onChangeClass.bind(this)} value={this.state.currentCharacterClass === null ? '0' : this.state.currentCharacterClass}>
                    {this._renderRaceCharacterClasses()}
                  </select>
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-sm-4">
                <div className="form-group">
                  <label htmlFor="character_main_role_id">{strings.mainRole}</label>
                  <select className="form-control form-control-sm" id="character_main_role_id" onChange={this._onChangeMainRole.bind(this)} value={this.state.currentMainRole === null ? '0' : this.state.currentMainRole}>
                    {this._renderClassRoles()}
                  </select>
                </div>
              </div>
              {this.state.secondaryRoles.length > 0 &&
                <div className="col-sm-4">
                  <div className="secondary_roles">
                    <p>{strings.otherRoles}</p>
                    {this._renderSecondaryRoles()}
                  </div>
                </div>
              }
            </div>
            <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
          </div>
        </div>
      </div>
    )
  }
}
