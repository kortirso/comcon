import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class CharacterForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      data: {},
      name: '',
      level: 60,
      worlds: [],
      dungeons: [],
      keyDungeons: [],
      questDungeons: [],
      raceCharacterClasses: {},
      roles: {},
      secondaryRoles: [],
      currentRace: null,
      currentCharacterClass: null,
      currentWorld: 0,
      currentMainRole: null,
      currentSecondaryRoles: {},
      currentDungeons: {},
      characterId: props.character_id,
      professions: [],
      currentProfessions: {},
      secondaryProfessionIds: [],
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
        const raceCharacterClasses = data.races[currentRace].character_classes
        const currentCharacterClass = Object.keys(raceCharacterClasses)[0]
        const roles = raceCharacterClasses[currentCharacterClass].roles
        const currentMainRole = Object.keys(roles)[0]

        const keyDungeons = data.dungeons.filter((dungeon) => {
          return dungeon.key_access
        })
        const questDungeons = data.dungeons.filter((dungeon) => {
          return dungeon.quest_access
        })
        let currentDungeons = {}
        data.dungeons.forEach((dungeon) => {
          currentDungeons[dungeon.id] = 0
        })
        let currentProfessions = {}
        let secondaryProfessionIds = []
        data.professions.forEach((profession) => {
          if (!profession.main) secondaryProfessionIds.push(profession.id)
          currentProfessions[profession.id] = 0
        })

        this.setState({worlds: data.worlds, dungeons: data.dungeons, keyDungeons: keyDungeons, questDungeons: questDungeons, currentDungeons: currentDungeons, data: data.races, races: data.races, currentRace: currentRace, raceCharacterClasses: raceCharacterClasses, currentCharacterClass: currentCharacterClass, roles: roles, currentMainRole: currentMainRole, professions: data.professions, currentProfessions: currentProfessions, secondaryProfessionIds: secondaryProfessionIds}, () => {
          this._getCharacter()
        })
      }
    })
  }

  _getCharacter() {
    if (this.state.characterId === undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/${this.state.characterId}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const character = data.character
        const raceCharacterClasses = this.state.data[character.race_id].character_classes
        const currentCharacterClass = character.character_class_id.toString()
        const roles = raceCharacterClasses[currentCharacterClass].roles
        const currentMainRole = character.main_role_id.toString()
        let currentDungeons = {}
        this.state.dungeons.forEach((dungeon) => {
          currentDungeons[dungeon.id] = (character.dungeon_ids.includes(parseInt(dungeon.id)) ? 1 : 0)
        })
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
        let currentProfessions = {}
        this.state.professions.forEach((profession) => {
          currentProfessions[profession.id] = (character.profession_ids.includes(parseInt(profession.id)) ? 1 : 0)
        })

        this.setState({name: character.name, level: character.level, currentRace: character.race_id, raceCharacterClasses: raceCharacterClasses, currentCharacterClass: currentCharacterClass, roles: roles, currentMainRole: currentMainRole, currentWorld: character.world_id, currentDungeons: currentDungeons, secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles, currentProfessions: currentProfessions})
      }
    })
  }

  _onCreate() {
    const state = this.state
    let currentSecondaryRoles = state.currentSecondaryRoles
    currentSecondaryRoles[state.currentMainRole] = '1'
    let url = `/api/v1/characters.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { character: { name: state.name, level: state.level, race_id: state.currentRace, character_class_id: state.currentCharacterClass, world_id: state.currentWorld, main_role_id: state.currentMainRole, roles: currentSecondaryRoles, dungeon: state.currentDungeons, professions: state.currentProfessions } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let currentSecondaryRoles = state.currentSecondaryRoles
    currentSecondaryRoles[state.currentMainRole] = '1'
    let url = `/api/v1/characters/${state.characterId}.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: { character: { name: state.name, level: state.level, race_id: state.currentRace, character_class_id: state.currentCharacterClass, world_id: state.currentWorld, main_role_id: state.currentMainRole, roles: currentSecondaryRoles, dungeon: state.currentDungeons, professions: state.currentProfessions } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _renderRaces() {
    return Object.entries(this.state.data).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _renderRaceCharacterClasses() {
    if (this.state.data[this.state.currentRace] === undefined) return false
    return Object.entries(this.state.data[this.state.currentRace].character_classes).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _renderWorlds() {
    return this.state.worlds.map((world) => {
      return <option value={world.id} key={world.id}>{world.name}</option>
    })
  }

  _renderClassRoles() {
    const race = this.state.data[this.state.currentRace]
    if (race === undefined) return false
    const characterClass = race.character_classes[this.state.currentCharacterClass]
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

  _renderProfessions() {
    return this.state.professions.map((profession) => {
      return (
        <div className="form-group form-check" key={profession.id}>
          <input className="form-check-input" type="checkbox" checked={this.state.currentProfessions[profession.id] === 1} onChange={this._onChangeProfession.bind(this, profession.id)} id={`character_professions[${profession.id}]`} />
          <label htmlFor={`character_professions[${profession.id}]`}>{profession.name[this.props.locale]}</label>
        </div>
      )
    })
  }

  _renderQuestDungeons() {
    return this.state.questDungeons.map((dungeon) => {
      return (
        <div className="form-group form-check" key={dungeon.id}>
          <input className="form-check-input" type="checkbox" checked={this.state.currentDungeons[dungeon.id] === 1} onChange={this._onChangeDungeon.bind(this, dungeon.id)} id={`character_dungeon[${dungeon.id}]`} />
          <label htmlFor={`character_dungeon[${dungeon.id}]`}>{dungeon.name[this.props.locale]}</label>
        </div>
      )
    })
  }

  _renderKeyDungeons() {
    return this.state.keyDungeons.map((dungeon) => {
      return (
        <div className="form-group form-check" key={dungeon.id}>
          <input className="form-check-input" type="checkbox" checked={this.state.currentDungeons[dungeon.id] === 1} onChange={this._onChangeDungeon.bind(this, dungeon.id)} id={`character_dungeon[${dungeon.id}]`} />
          <label htmlFor={`character_dungeon[${dungeon.id}]`}>{dungeon.name[this.props.locale]}</label>
        </div>
      )
    })
  }

  _renderSubmitButton() {
    if (this.state.characterId === undefined) return <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
    return <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
  }

  _onChangeRace(event) {
    const currentRace = event.target.value
    const raceCharacterClasses = this.state.data[currentRace].character_classes
    const currentCharacterClass = Object.keys(raceCharacterClasses)[0]

    this.setState({currentRace: currentRace, raceCharacterClasses: raceCharacterClasses}, () => {
      this._onChangeClass(currentCharacterClass)
    })
  }

  _onChangeClass(event) {
    const currentCharacterClass = event.target === undefined ? event : event.target.value
    const roles = this.state.raceCharacterClasses[currentCharacterClass].roles
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

  _onChangeProfession(professionId) {
    let professions = this.state.currentProfessions
    if (professions[professionId] === 1) {
      professions[professionId] = 0
      this.setState({currentProfessions: professions})
    } else {
      let existedProfessions = 0
      let mainProfessions = 0
      let currentSelectingProfession = {}

      this.state.professions.forEach((profession) => {
        if (professions[profession.id] === 1) {
          existedProfessions += 1
          if (profession.main) mainProfessions += 1
        }
        if (profession.id === professionId) currentSelectingProfession = profession
      })

      if (existedProfessions < 2 || existedProfessions === 2 && (!currentSelectingProfession.main || mainProfessions === 1)) {
        professions[professionId] = (professions[professionId] === 0 ? 1 : 0)
        this.setState({currentProfessions: professions})
      } else return false
    }
  }

  _onChangeDungeon(dungeonId) {
    let dungeons = this.state.currentDungeons
    dungeons[dungeonId] = (dungeons[dungeonId] === 0 ? 1 : 0)
    this.setState({currentDungeons: dungeons})
  }

  render() {
    return (
      <div className="character_form">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="row">
          <div className="col-xl-6">
            <div className="row">
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_name">{strings.name}</label>
                  <input required="required" placeholder={strings.nameLabel} className="form-control form-control-sm" type="text" id="character_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
                </div>
              </div>
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_level">{strings.level}</label>
                  <input required="required" placeholder={strings.level} className="form-control form-control-sm" type="number" id="character_level" value={this.state.level} onChange={(event) => this.setState({level: event.target.value})} />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_race_id">{strings.race}</label>
                  <select className="form-control form-control-sm" id="character_race_id" onChange={this._onChangeRace.bind(this)} value={this.state.currentRace === null ? '0' : this.state.currentRace} disabled={this.state.characterId !== undefined}>
                    {this._renderRaces()}
                  </select>
                </div>
              </div>
              <div className="col-sm-6">
                <div className="form-group">
                  <label htmlFor="character_character_class_id">{strings.characterClass}</label>
                  <select className="form-control form-control-sm" id="character_character_class_id" onChange={this._onChangeClass.bind(this)} value={this.state.currentCharacterClass === null ? '0' : this.state.currentCharacterClass} disabled={this.state.characterId !== undefined}>
                    {this._renderRaceCharacterClasses()}
                  </select>
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-sm-4">
                <div className="form-group">
                  <label htmlFor="world_id">{strings.world}</label>
                  <select className="form-control form-control-sm" id="world_id" onChange={this._onChangeWorld.bind(this)} value={this.state.currentWorld} disabled={this.state.characterId !== undefined}>
                    <option value="0"></option>
                    {this._renderWorlds()}
                  </select>
                </div>
              </div>
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
            {this._renderSubmitButton()}
          </div>
          <div className="col-xl-6">
            {this.state.professions.length > 0 &&
              <div className="row block">
                <div className="col">
                  <div className="form-group">
                    <h4>{strings.professions}</h4>
                    <div className="professions">
                      {this._renderProfessions()}
                    </div>
                  </div>
                </div>
              </div>
            }
            {this.state.dungeons.length > 0 &&
              <div>
                <div className="row block">
                  {this.state.questDungeons.length > 0 &&
                    <div className="col">
                      <div className="form-group">
                        <h4>{strings.quests}</h4>
                        <div className="professions">
                          {this._renderQuestDungeons()}
                        </div>
                      </div>
                    </div>
                  }
                </div>
                <div className="row">
                  {this.state.keyDungeons.length > 0 &&
                    <div className="col">
                      <div className="form-group">
                        <h4>{strings.keys}</h4>
                        <div className="professions">
                          {this._renderKeyDungeons()}
                        </div>
                      </div>
                    </div>
                  }
                </div>
              </div>
            }
          </div>
        </div>
      </div>
    )
  }
}
