import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

let strings = new LocalizedStrings(I18nData)

const classes = {
  Druid: "Друид",
  Paladin: "Паладин",
  Warrior: "Воин",
  Priest: "Жрец",
  Shaman: "Шаман",
  Rogue: "Разбойник",
  Hunter: "Охотник",
  Warlock: "Чернокнижник",
  Mage: "Маг"
}

const roles = {
  Tanks: "Танки",
  Healers: "Лекари",
  Dd: "ДД"
}

export default class RaidPlanner extends React.Component {
  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _capitalize(value) {
    if (typeof value !== 'string') return ''
    return value.charAt(0).toUpperCase() + value.slice(1)
  }

  _renderRoles(key) {
    const value = this.props.groupRoles[key]
    if (value === undefined) return false
    return (
      <div className="raid_role" key={key}>
        <p>{this.props.locale === 'en' ? this._capitalize(key) : roles[this._capitalize(key)]}</p>
        {this._renderRoleByClass(key, value["by_class"])}
      </div>
    )
  }

  _renderRoleByClass(role, byClass) {
    return Object.entries(byClass).map(([key, value]) => {
      return (
        <div className="role_by_class" key={key}>
          <span>{this.props.locale === 'en' ? this._capitalize(key) : classes[this._capitalize(key)]}</span>
          <input value={value === 0 ? '' : value} onChange={(event) => this.props.onChangeClassAmount(role, key, event.target.value)} />
        </div>
      )
    })
  }

  render() {
    return (
      <div className="raid_planner">
        <h3>{strings.title}</h3>
        {this._renderRoles("tanks")}
        {this._renderRoles("healers")}
        {this._renderRoles("dd")}
      </div>
    )
  }
}
