import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

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
      guilds: [],
      dungeons: [],
      keyDungeons: [],
      questDungeons: [],
      raceCharacterClasses: {},
      roles: {},
      secondaryRoles: [],
      currentRace: null,
      currentCharacterClass: null,
      currentWorld: 0,
      currentGuild: 0,
      currentMainRole: null,
      currentSecondaryRoles: {},
      currentDungeons: {},
      characterId: props.character_id
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

        this.setState({worlds: data.worlds, guilds: data.guilds, dungeons: data.dungeons, keyDungeons: keyDungeons, questDungeons: questDungeons, currentDungeons: currentDungeons, data: data.races, races: data.races, currentRace: currentRace, raceCharacterClasses: raceCharacterClasses, currentCharacterClass: currentCharacterClass, roles: roles, currentMainRole: currentMainRole}, () => {
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
        let currentGuild
        let currentWorld
        if (character.guild_id === null) {
          currentGuild = 0
          currentWorld = character.world_id
        } else {
          currentWorld = 0
          currentGuild = character.guild_id
        }
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

        this.setState({name: character.name, level: character.level, currentRace: character.race_id, raceCharacterClasses: raceCharacterClasses, currentCharacterClass: currentCharacterClass, roles: roles, currentMainRole: currentMainRole, currentGuild: currentGuild, currentWorld: currentWorld, currentDungeons: currentDungeons, secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
      }
    })
  }

  _onCreate() {
    const state = this.state
    let currentSecondaryRoles = state.currentSecondaryRoles
    currentSecondaryRoles[state.currentMainRole] = '1'
    $.ajax({
      method: 'POST',
      url: `/api/v1/characters.json?access_token=${this.props.access_token}`,
      data: { character: { name: state.name, level: state.level, race_id: state.currentRace, character_class_id: state.currentCharacterClass, guild_id: state.currentGuild, world_id: state.currentWorld, main_role_id: state.currentMainRole, roles: currentSecondaryRoles, dungeon: state.currentDungeons } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let currentSecondaryRoles = state.currentSecondaryRoles
    currentSecondaryRoles[state.currentMainRole] = '1'
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/characters/${state.characterId}.json?access_token=${this.props.access_token}`,
      data: { character: { name: state.name, level: state.level, race_id: state.currentRace, character_class_id: state.currentCharacterClass, guild_id: state.currentGuild, world_id: state.currentWorld, main_role_id: state.currentMainRole, roles: currentSecondaryRoles, dungeon: state.currentDungeons } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
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

  _renderGuilds() {
    return this.state.guilds.map((guild) => {
      return <option value={guild.id} key={guild.id}>{guild.full_name}</option>
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

  _onChangeGuild(event) {
    if (event.target.value === '0') this.setState({currentGuild: 0})
    else {
      const guilds = this.state.guilds.filter((guild) => {
        return guild.id === parseInt(event.target.value)
      })
      this.setState({currentGuild: guilds[0].id, currentWorld: 0})
    }
  }

  _onChangeWorld(event) {
    if (event.target.value === '0') this.setState({currentWorld: 0})
    else {
      const worlds = this.state.worlds.filter((world) => {
        return world.id === parseInt(event.target.value)
      })
      this.setState({currentWorld: worlds[0].id, currentGuild: 0})
    }
  }

  _onChangeRole(roleId) {
    let roles = this.state.currentSecondaryRoles
    roles[roleId] = (roles[roleId] === 0 ? 1 : 0)
    this.setState({currentSecondaryRoles: roles})
  }

  _onChangeDungeon(dungeonId) {
    let dungeons = this.state.currentDungeons
    dungeons[dungeonId] = (dungeons[dungeonId] === 0 ? 1 : 0)
    this.setState({currentDungeons: dungeons})
  }

  render() {
    return (
      <div className="character_form">
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="character_name">{strings.name}</label>
            <input required="required" placeholder={strings.nameLabel} className="form-control" type="text" id="character_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
          </div>
          <div className="form-group">
            <label htmlFor="character_level">{strings.level}</label>
            <input required="required" placeholder={strings.level} className="form-control" type="number" id="character_level" value={this.state.level} onChange={(event) => this.setState({level: event.target.value})} />
          </div>
        </div>
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="character_race_id">{strings.race}</label>
            <select className="form-control" id="character_race_id" onChange={this._onChangeRace.bind(this)} value={this.state.currentRace === null ? '0' : this.state.currentRace}>
              {this._renderRaces()}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="character_character_class_id">{strings.characterClass}</label>
            <select className="form-control" id="character_character_class_id" onChange={this._onChangeClass.bind(this)} value={this.state.currentCharacterClass === null ? '0' : this.state.currentCharacterClass}>
              {this._renderRaceCharacterClasses()}
            </select>
          </div>
        </div>
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="character_guild_id">{strings.guild}</label>
              <select className="form-control" id="character_guild_id" onChange={this._onChangeGuild.bind(this)} value={this.state.currentGuild}>
                <option value="0"></option>
                {this._renderGuilds()}
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="world_id">{strings.world}</label>
              <select className="form-control" id="world_id" onChange={this._onChangeWorld.bind(this)} value={this.state.currentWorld}>
                <option value="0"></option>
                {this._renderWorlds()}
              </select>
            </div>
          </div>
          <div className="form-group roles">
            <div className="main_role">
              <label htmlFor="character_main_role_id">{strings.mainRole}</label>
              <select className="form-control" id="character_main_role_id" onChange={this._onChangeMainRole.bind(this)} value={this.state.currentMainRole === null ? '0' : this.state.currentMainRole}>
                {this._renderClassRoles()}
              </select>
            </div>
            {this.state.secondaryRoles.length > 0 &&
              <div className="secondary_roles">
                <p>{strings.otherRoles}</p>
                {this._renderSecondaryRoles()}
              </div>
            }
          </div>
        </div>
        {this.state.dungeons.length > 0 &&
          <div className="double_line">
            {this.state.questDungeons.length > 0 &&
              <div className="block">
                <p>{strings.quests}</p>
                {this._renderQuestDungeons()}
              </div>
            }
            {this.state.keyDungeons.length > 0 &&
              <div className="block">
                <p>{strings.keys}</p>
                {this._renderKeyDungeons()}
              </div>
            }
          </div>
        }
        {this.state.characterId === undefined &&
          <input type="submit" name="commit" value="Создать" className="btn btn-primary" onClick={this._onCreate.bind(this)} />
        }
        {this.state.characterId !== undefined &&
          <input type="submit" name="commit" value="Обновить" className="btn btn-primary" onClick={this._onUpdate.bind(this)} />
        }
      </div>
    )
  }
}
