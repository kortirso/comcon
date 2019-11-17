import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

export default class Craft extends React.Component {
  constructor() {
    super()
    this.typingTimeout = 0
    this.state = {
      professions: [],
      worlds: [],
      fractions: [],
      guilds: [],
      currentGuilds: [],
      profession: '0',
      world: '0',
      guild: '0',
      fraction: '0',
      crafters: [],
      searched: false,
      query: '',
      searchedRecipes: [],
      recipe: '0'
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getFilterValues()
  }

  componentWillUnmount() {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  _getFilterValues() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/craft/filter_values.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const professions = data.professions.filter((profession) => {
          return profession.recipeable
        })
        this.setState({worlds: data.worlds, fractions: data.fractions, guilds: data.guilds, currentGuilds: data.guilds, professions: professions})
      }
    })
  }

  _findCrafters() {
    const state = this.state
    let params = [`recipe_id=${state.recipe}`]
    if (state.world !== '0') params.push(`world_id=${state.world}`)
    if (state.fraction !== '0') params.push(`fraction_id=${state.fraction}`)
    if (state.guild !== '0') params.push(`guild_id=${state.guild}`)
    const url = `/api/v1/craft/search.json?access_token=${this.props.access_token}&` + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({crafters: data.characters, searched: true})
      }
    })
  }

  _searchRecipes() {
    let url = `/api/v1/recipes/search.json?access_token=${this.props.access_token}&query=${this.state.query}`
    if (this.state.profession !== '0') url += `&profession_id=${this.state.profession}`
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({searchedRecipes: data.recipes})
      }
    })
  }

  _renderFilters() {
    return (
      <div className="filters">
        <div className="filter-block">
          {this._renderWorldFilter()}
          {this._renderFractionFilter()}
          {this._renderGuildFilter()}
          <button className="btn btn-primary btn-sm with_left_margin" onClick={this._findCrafters.bind(this)}>{strings.search}</button>
        </div>
        <div className="filter-block">
          {this._renderProfessionFilter()}
          {this._renderRecipeFilter()}
        </div>
      </div>
    )
  }

  _renderProfessionFilter() {
    return (
      <div className="filter profession">
        <p>{strings.filterProfession}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeProfession.bind(this)} value={this.state.profession}>
          <option value='0' key='0'>{strings.none}</option>
          {this._renderProfessionsList()}
        </select>
      </div>
    )
  }

  _renderProfessionsList() {
    return this.state.professions.map((profession) => {
      return <option value={profession.id} key={profession.id}>{profession.name[this.props.locale]}</option>
    })
  }

  _renderRecipeFilter() {
    return (
      <div className="filter recipe">
        <p>{strings.filterRecipe}</p>
        <div className="search_recipe_block">
          <input placeholder={strings.recipesSearch} className="form-control form-control-sm" type="text" id="query" value={this.state.query} onChange={this._onChangeQuery.bind(this)} />
          <div className="search_recipe_results">
            {this._renderSearchRecipeResults()}
          </div>
        </div>
      </div>
    )
  }

  _onChangeQuery(event) {
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
    const queryValue = event.target.value
    if (queryValue.length < 3) return this.setState({query: queryValue})
    else this.setState({query: queryValue}, () => {
      this.typingTimeout = setTimeout(() => {
        this._searchRecipes()
      }, 1000)
    })
  }

  _renderSearchRecipeResults() {
    if (this.state.searchedRecipes.length === 0) return false
    return this.state.searchedRecipes.map((recipe) => {
      return <p className="value" onClick={this._onSelectRecipe.bind(this, recipe)} key={recipe.id}>{recipe.name[this.props.locale]}</p>
    })
  }

  _onSelectRecipe(recipe) {
    this.setState({query: recipe.name[this.props.locale], searchedRecipes: [], recipe: recipe.id})
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

  _renderGuildFilter() {
    return (
      <div className="filter guild">
        <p>{strings.filterGuild}</p>
        <select className="form-control form-control-sm" onChange={this._onChangeGuild.bind(this)} value={this.state.guild}>
          <option value='0' key='0'>{strings.none}</option>
          {this._renderGuildsList()}
        </select>
      </div>
    )
  }

  _renderGuildsList() {
    return this.state.currentGuilds.map((guild) => {
      return <option value={guild.id} key={guild.id}>{guild.full_name}</option>
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

  _renderCharactersList() {
    if (this.state.crafters.length === 0) return <div>{this._renderSearchStatus()}<p>{strings.noData}</p></div>
    return (
      <div className="characters">
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.race}</th>
              <th>{strings.level}</th>
              <th>{strings.guild}</th>
              <th>{strings.world}</th>
            </tr>
          </thead>
          <tbody>
            {this._renderCharacters()}
          </tbody>
        </table>
      </div>
    )
  }

  _renderSearchStatus() {
    if (this.state.searched) return <p>{strings.searchTrue}</p>
    else return false
  }

  _renderCharacters() {
    return this.state.crafters.map((character) => {
      return (
        <tr className={character.character_class.en} key={character.id}>
          <td className='character_link' onClick={this._goToCharacter.bind(this, character.slug)}>{character.name}</td>
          <td>{character.race[this.props.locale]}</td>
          <td>{character.level}</td>
          <td>{character.guild}</td>
          <td>{character.world}</td>
        </tr>
      )
    })
  }

  _goToCharacter(characterSlug) {
    window.location.href = `${this.props.locale === 'en' ? '' : '/' + this.props.locale}/characters/${characterSlug}`
  }

  _onChangeProfession(event) {
    this.setState({profession: event.target.value, query: '', recipe: '0'})
  }

  _onChangeWorld(event) {
    this.setState({world: event.target.value}, () => {
      this._onChangeGuild('0')
    })
  }

  _onChangeFraction(event) {
    this.setState({fraction: event.target.value}, () => {
      this._onChangeGuild('0')
    })
  }

  _onChangeGuild(event) {
    const guild = event.target === undefined ? event : event.target.value
    this.setState({guild: guild}, () => {
      if (this.state.guild !== '0') {
        const currentGuild = this.state.guilds.filter((guild) => {
          return guild.id === parseInt(this.state.guild)
        })[0]
        this.setState({world: currentGuild.world.id, fraction: currentGuild.fraction.id}, () => {
          this._setCurrentGuild()
        })
      } else this._setCurrentGuild()
    })
  }

  _setCurrentGuild() {
    const currentGuilds = this.state.guilds.filter((guild) => {
      if (this.state.fraction !== '0' && this.state.world !== '0') return guild.fraction.id === parseInt(this.state.fraction) && guild.world.id === parseInt(this.state.world)
      else if (this.state.fraction !== '0' && this.state.world === '0') return guild.fraction.id === parseInt(this.state.fraction)
      else if (this.state.fraction === '0' && this.state.world !== '0') return guild.world.id === parseInt(this.state.world)
      else return true
    })
    this.setState({currentGuilds: currentGuilds})
  }

  render() {
    return (
      <div>
        {this._renderFilters()}
        {this._renderCharactersList()}
      </div>
    )
  }
}
