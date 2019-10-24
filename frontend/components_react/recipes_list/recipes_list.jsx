import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class RecipesList extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      professions: [],
      profession: 0,
      recipes: []
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getProfessions()
  }

  _getProfessions() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/professions.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const professions = data.professions.filter((profession) => {
          return profession.recipeable
        })
        this.setState({professions: professions})
      }
    })
  }

  _getRecipes() {
    let params = []
    if (this.state.profession !== '0') params.push(`profession_id=${this.state.profession}`)
    const url = `/api/v1/recipes.json?access_token=${this.props.access_token}&` + params.join('&')
    $.ajax({
      method: 'GET',
      url: url,
      success: (data) => {
        this.setState({recipes: data.recipes})
      }
    })
  }

  _renderFilters() {
    return (
      <div className="filters">
        {this._renderProfessionFilter()}
      </div>
    )
  }

  _renderProfessionFilter() {
    return (
      <div className="filter profession">
        <p>{strings.filterProfession}</p>
        <select className="form-control" onChange={this._onChangeProfession.bind(this)} value={this.state.profession}>
          <option value='0' key='0'>{strings.all}</option>
          {this._renderProfessions()}
        </select>
      </div>
    )
  }

  _renderProfessions() {
    return this.state.professions.map((profession) => {
      return <option value={profession.id} key={profession.id}>{profession.name[this.props.locale]}</option>
    })
  }

  _onChangeProfession(event) {
    this.setState({profession: event.target.value}, () => {
      this._getRecipes()
    })
  }

  _renderRecipes() {
    return this.state.recipes.map((recipe) => {
      return (
        <tr key={recipe.id}>
          <td>{recipe.id}</td>
          <td>{recipe.name[this.props.locale]}</td>
          <td><a href={recipe.links[this.props.locale]}>{recipe.name[this.props.locale]}</a></td>
          <td>{recipe.skill}</td>
          <td>
            <a className="btn btn-primary btn-sm with_right_margin" href={`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/recipes/${recipe.id}/edit`}>{strings.edit}</a>
            <a data-confirm="Are you sure?" className="btn btn-primary btn-sm" rel="nofollow" data-method="delete" href={`/recipes/${recipe.id}`}>{strings.deleteButton}</a>
          </td>
        </tr>
      )
    })
  }

  render() {
    return (
      <div className="recipes">
        {this._renderFilters()}
        <table className="table table-striped">
          <thead>
            <tr>
              <th>{strings.id}</th>
              <th>{strings.name}</th>
              <th>{strings.links}</th>
              <th>{strings.skill}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this._renderRecipes()}
          </tbody>
        </table>
      </div>
    )
  }
}
