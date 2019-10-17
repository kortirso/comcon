import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

const raceClassCombinations = {
  "Human": ["Mage", "Paladin", "Priest", "Rogue", "Warlock", "Warrior"],
  "Dwarf": ["Rogue", "Hunter", "Paladin", "Priest", "Warrior"],
  "Gnome": ["Mage", "Rogue", "Warlock", "Warrior"],
  "Night Elf": ["Druid", "Hunter", "Priest", "Rogue", "Warrior"],
  "Orc": ["Rogue", "Warlock", "Hunter", "Shaman", "Warrior"],
  "Troll": ["Hunter", "Mage", "Priest", "Rogue", "Shaman", "Warrior"],
  "Tauren": ["Druid", "Hunter", "Shaman", "Warrior"],
  "Undead": ["Mage", "Priest", "Rogue", "Warlock", "Warrior"]
}

const classRolesCombinations = {
  "Mage": ["Ranged"],
  "Priest": ["Healer", "Ranged"],
  "Warlock": ["Ranged"],
  "Rogue": ["Melee"],
  "Druid": ["Tank", "Healer", "Melee", "Ranged"],
  "Hunter": ["Ranged"],
  "Shaman": ["Healer", "Melee", "Ranged"],
  "Paladin": ["Tank", "Healer", "Melee"],
  "Warrior": ["Tank", "Melee"]
}

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class CharacterForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      name: '',
      level: 60,
      races: [],
      characterClasses: [],
      raceCharacterClasses: [],
      worlds: [],
      guilds: [],
      roles: [],
      dungeons: [],
      keyDungeons: [],
      questDungeons: [],
      currentRace: null,
      currentCharacterClass: null,
      currentWorld: { id: 0 },
      currentGuild: { id: 0 },
      currentRoles: [],
      currentMainRole: null,
      secondaryRoles: [],
      currentSecondaryRoles: {},
      currentDungeons: {},
      characterId: props.character_id
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getDefaultValues()
  }

  _getDefaultValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/default_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const raceCharacterClasses = this._filterRaceCharacterClasses(data.character_classes, data.races[0])
        const classRoles = this._filterClassRoles(data.roles, raceCharacterClasses[0])
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

        this.setState({worlds: data.worlds, guilds: data.guilds, races: data.races, currentRace: data.races[0], characterClasses: data.character_classes, raceCharacterClasses: raceCharacterClasses, currentCharacterClass: raceCharacterClasses[0], roles: data.roles, currentRoles: classRoles, currentMainRole: classRoles[0], dungeons: data.dungeons, keyDungeons: keyDungeons, questDungeons: questDungeons, currentDungeons: currentDungeons}, () => {
          this._getCharacter()
        })
      }
    })
  }

  _filterRaceCharacterClasses(characterClasses, currentRace) {
    return characterClasses.filter((characterClass) => {
      return raceClassCombinations[currentRace.name.en].includes(characterClass.name.en)
    })
  }

  _filterClassRoles(roles, raceCharacterClass) {
    return roles.filter((role) => {
      return classRolesCombinations[raceCharacterClass.name.en].includes(role.name.en)
    })
  }

  _getCharacter() {
    if (this.state.characterId === undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/characters/${this.state.characterId}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const character = data.character

        const race = this.state.races.filter((race) => {
          return race.name.en === character.race.en
        })[0]
        const characterClass = this.state.characterClasses.filter((characterClass) => {
          return characterClass.name.en === character.character_class.en
        })[0]
        const raceCharacterClasses = this._filterRaceCharacterClasses(this.state.characterClasses, race)
        const classRoles = this._filterClassRoles(this.state.roles, characterClass)
        const mainRole = this.state.roles.filter((role) => {
          return role.name.en === character.main_role.en
        })[0]
        let currentGuild
        let currentWorld
        if (character.guild === null) {
          currentGuild = { id: 0 }
          currentWorld = this.state.worlds.filter((world) => {
            return world.name === character.world
          })[0]
        } else {
          currentWorld = { id: 0 }
          currentGuild = this.state.guilds.filter((guild) => {
            return guild.full_name === character.guild
          })[0]
        }
        const dungeonIds = character.dungeons.map((dungeon) => {
          return dungeon.id
        })
        let currentDungeons = {}
        this.state.dungeons.forEach((dungeon) => {
          currentDungeons[dungeon.id] = (dungeonIds.includes(dungeon.id) ? 1 : 0)
        })

        const secondaryRoles = classRoles.filter((role) => {
          return role.id !== mainRole.id
        })
        const secIds = character.secondary_roles.map((role) => {
          return role.id
        })
        let currentSecondaryRoles = {}
        secondaryRoles.forEach((role) => {
          currentSecondaryRoles[role.id] = (secIds.includes(role.id) ? 1 : 0)
        })
        const secNames = secondaryRoles.map((role) => {
          return role.name.en
        })

        this.setState({name: character.name, level: character.level, currentRace: race, raceCharacterClasses: raceCharacterClasses, currentCharacterClass: characterClass, currentRoles: classRoles, currentMainRole: mainRole, currentGuild: currentGuild, currentWorld: currentWorld, currentDungeons: currentDungeons, secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
      }
    })
  }

  _onCreate() {
    const state = this.state
    let currentSecondaryRoles = state.currentSecondaryRoles
    currentSecondaryRoles[state.currentMainRole.id] = '1'
    $.ajax({
      method: 'POST',
      url: `/api/v1/characters.json?access_token=${this.props.access_token}`,
      data: { character: { name: state.name, level: state.level, race_id: state.currentRace.id, character_class_id: state.currentCharacterClass.id, guild_id: state.currentGuild.id, world_id: state.currentWorld.id, main_role_id: state.currentMainRole.id, roles: currentSecondaryRoles, dungeon: state.currentDungeons } },
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
    currentSecondaryRoles[state.currentMainRole.id] = '1'
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/characters/${state.characterId}.json?access_token=${this.props.access_token}`,
      data: { character: { name: state.name, level: state.level, race_id: state.currentRace.id, character_class_id: state.currentCharacterClass.id, guild_id: state.currentGuild.id, world_id: state.currentWorld.id, main_role_id: state.currentMainRole.id, roles: currentSecondaryRoles, dungeon: state.currentDungeons } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
      }
    })
  }

  _renderRaces() {
    return this.state.races.map((race) => {
      return <option value={race.id} key={race.id}>{race.name[this.props.locale]}</option>
    })
  }

  _renderRaceCharacterClasses() {
    return this.state.raceCharacterClasses.map((characterClass) => {
      return <option value={characterClass.id} key={characterClass.id}>{characterClass.name[this.props.locale]}</option>
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
    return this.state.currentRoles.map((role) => {
      return <option value={role.id} key={role.id}>{role.name[this.props.locale]}</option>
    })
  }

  _renderSecondaryRoles() {
    return this.state.currentRoles.map((role) => {
      if (this.state.secondaryRoles.includes(role.name.en)) {
        return (
          <div className="form-group form-check" key={role.id}>
            <input className="form-check-input" type="checkbox" checked={this.state.currentSecondaryRoles[role.id] === 1} onChange={this._onChangeRole.bind(this, role.id)} id={`character_roles[${role.id}]`} />
            <label htmlFor={`character_roles[${role.id}]`}>{role.name[this.props.locale]}</label>
          </div>
        )
      } else return false
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

  _onChangeRace(event) {
    const races = this.state.races.filter((race) => {
      return race.id === parseInt(event.target.value)
    })
    const raceCharacterClasses = this._filterRaceCharacterClasses(this.state.characterClasses, races[0])
    const classRoles = this._filterClassRoles(this.state.roles, raceCharacterClasses[0])
    const secondaryRoles = classRoles.filter((role) => {
      return role.id !== classRoles[0].id
    })
    let currentSecondaryRoles = {}
    secondaryRoles.forEach((role) => {
      currentSecondaryRoles[role.id] = 0
    })
    const secNames = secondaryRoles.map((role) => {
      return role.name.en
    })

    this.setState({currentRace: races[0], raceCharacterClasses: raceCharacterClasses, currentCharacterClass: raceCharacterClasses[0], currentRoles: classRoles, currentMainRole: classRoles[0], secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
  }

  _onChangeClass(event) {
    const characterClasses = this.state.characterClasses.filter((characterClass) => {
      return characterClass.id === parseInt(event.target.value)
    })
    const classRoles = this._filterClassRoles(this.state.roles, characterClasses[0])
    const secondaryRoles = classRoles.filter((role) => {
      return role.id !== classRoles[0].id
    })
    let currentSecondaryRoles = {}
    secondaryRoles.forEach((role) => {
      currentSecondaryRoles[role.id] = 0
    })
    const secNames = secondaryRoles.map((role) => {
      return role.name.en
    })
    this.setState({currentCharacterClass: characterClasses[0], currentRoles: classRoles, currentMainRole: classRoles[0], secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
  }

  _onChangeGuild(event) {
    if (event.target.value === '0') this.setState({currentGuild: { id: 0 }})
    else {
      const guilds = this.state.guilds.filter((guild) => {
        return guild.id === parseInt(event.target.value)
      })
      this.setState({currentGuild: guilds[0], currentWorld: { id: 0 }})
    }
  }

  _onChangeWorld(event) {
    if (event.target.value === '0') this.setState({currentWorld: { id: 0 }})
    else {
      const worlds = this.state.worlds.filter((world) => {
        return world.id === parseInt(event.target.value)
      })
      this.setState({currentWorld: worlds[0], currentGuild: { id: 0 }})
    }
  }

  _onChangeMainRole(event) {
    const roles = this.state.roles.filter((role) => {
      return role.id === parseInt(event.target.value)
    })
    const secondaryRoles = this.state.currentRoles.filter((role) => {
      return role.id !== roles[0].id
    })
    let currentSecondaryRoles = {}
    secondaryRoles.forEach((role) => {
      currentSecondaryRoles[role.id] = 0
    })
    const secNames = secondaryRoles.map((role) => {
      return role.name.en
    })
    this.setState({currentMainRole: roles[0], secondaryRoles: secNames, currentSecondaryRoles: currentSecondaryRoles})
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
            <label htmlFor="character_name">Имя</label>
            <input required="required" placeholder="Имя персонажа" className="form-control" type="text" id="character_name" value={this.state.name} onChange={(event) => this.setState({name: event.target.value})} />
          </div>
          <div className="form-group">
            <label htmlFor="character_level">Уровень</label>
            <input required="required" placeholder="Уровень" className="form-control" type="number" id="character_level" value={this.state.level} onChange={(event) => this.setState({level: event.target.value})} />
          </div>
        </div>
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="character_race_id">Раса</label>
            <select className="form-control" id="character_race_id" onChange={this._onChangeRace.bind(this)} value={this.state.currentRace === null ? '0' : this.state.currentRace.id}>
              {this._renderRaces()}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="character_character_class_id">Класс</label>
            <select className="form-control" id="character_character_class_id" onChange={this._onChangeClass.bind(this)} value={this.state.currentCharacterClass === null ? '0' : this.state.currentCharacterClass.id}>
              {this._renderRaceCharacterClasses()}
            </select>
          </div>
        </div>
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="character_guild_id">Гильдия</label>
              <select className="form-control" id="character_guild_id" onChange={this._onChangeGuild.bind(this)} value={this.state.currentGuild.id}>
                <option value="0"></option>
                {this._renderGuilds()}
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="world_id">Игровой Мир</label>
              <select className="form-control" id="world_id" onChange={this._onChangeWorld.bind(this)} value={this.state.currentWorld.id}>
                <option value="0"></option>
                {this._renderWorlds()}
              </select>
            </div>
          </div>
          <div className="form-group roles">
            <div className="main_role">
              <label htmlFor="character_main_role_id">Главная роль</label>
              <select className="form-control" name="character[main_role_id]" id="character_main_role_id" onChange={this._onChangeMainRole.bind(this)} value={this.state.currentMainRole === null ? '0' : this.state.currentMainRole.id}>
                {this._renderClassRoles()}
              </select>
            </div>
            {this.state.secondaryRoles.length > 0 &&
              <div className="secondary_roles">
                <p>Другие роли</p>
                {this._renderSecondaryRoles()}
              </div>
            }
          </div>
        </div>
        {this.state.dungeons.length > 0 &&
          <div className="double_line">
            {this.state.questDungeons.length > 0 &&
              <div className="block">
                <p>Выполненные квесты для подземелий</p>
                {this._renderQuestDungeons()}
              </div>
            }
          </div>
        }
        {this.state.characterId === null &&
          <input type="submit" name="commit" value="Создать" className="btn btn-primary" onClick={this._onCreate.bind(this)} />
        }
        {this.state.characterId !== null &&
          <input type="submit" name="commit" value="Обновить" className="btn btn-primary" onClick={this._onUpdate.bind(this)} />
        }
      </div>
    )
  }
}
