import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class GuildsList extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      fractions: [],
      worlds: [],
      guilds: [],
      filteredGuilds: [],
      fraction: '0',
      world: '0'
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getFractions()
  }

  componentDidMount() {
    this._getGuilds()
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

  _getGuilds() {
    let params = []
    const url = `/api/v1/guilds.json?access_token=${this.props.access_token}&` + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({guilds: data.guilds}, () => {
          this._filterGuilds()
        })
      }
    })
  }

  _filterGuilds() {
    const state = this.state
    let filters = {}
    if (state.fraction !== '0') filters['fraction_id'] = parseInt(state.fraction)
    if (state.world !== '0') filters['world_id'] = parseInt(state.world)
    const guilds = state.guilds.filter(function(guild) {
      for (var key in filters) {
        if (guild[key] === undefined || guild[key] != filters[key]) return false
      }
      return true
    })
    this.setState({filteredGuilds: guilds})
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderWorldFilter()}
        {this._renderFractionFilter()}
        <a className="btn btn-primary btn-sm" href={`${this.props.locale === 'en' ? '' : '/' + this.props.locale}/guilds/new`}>{strings.addGuild}</a>
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

  _renderGuilds() {
    return this.state.filteredGuilds.map((guild) => {
      return (
        <tr className="guild_link" onClick={this._goToGuild.bind(this, guild.slug)} key={guild.id}>
          <td className={guild.fraction_name.en.toLowerCase()}>{guild.name}</td>
          <td>{guild.world_name}</td>
          <td>
            <p>{guild.description}</p>
          </td>
        </tr>
      )
    })
  }

  _onChangeWorld(event) {
    this.setState({world: event.target.value}, () => {
      this._filterGuilds()
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value}, () => {
      this._filterGuilds()
    })
  }

  _goToGuild(guildSlug) {
    window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/guilds/${guildSlug}`
  }

  render() {
    return (
      <div className="guilds">
        <h2>{strings.guilds}</h2>
        {this._renderFilters()}
        <table className="table table-striped table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.world}</th>
              <th>{strings.description}</th>
            </tr>
          </thead>
          <tbody>
            {this._renderGuilds()}
          </tbody>
        </table>
      </div>
    )
  }
}
