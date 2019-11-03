import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class RecipeForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      name: { en: '', ru: '' },
      links: { en: '', ru: '' },
      skill: 300,
      professions: [],
      profession: 0
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
        this.setState({professions: professions}, () => {
          this._getRecipe()
        })
      }
    })
  }

  _getRecipe() {
    if (this.props.recipe_id === undefined) return false
    $.ajax({
      method: 'GET',
      url: `/api/v1/recipes/${this.props.recipe_id}.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const recipe = data.recipe
        this.setState({name: recipe.name, links: recipe.links, skill: recipe.skill, profession: recipe.profession_id})
      }
    })
  }

  _onCreate() {
    const state = this.state
    $.ajax({
      method: 'POST',
      url: `/api/v1/recipes.json?access_token=${this.props.access_token}`,
      data: { recipe: { name: state.name, links: state.links, skill: state.skill, profession_id: state.profession } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/recipes`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
      }
    })
  }

  _onUpdate() {
    const state = this.state
    $.ajax({
      method: 'PATCH',
      url: `/api/v1/recipes/${this.props.recipe_id}.json?access_token=${this.props.access_token}`,
      data: { recipe: { name: state.name, links: state.links, skill: state.skill, profession_id: state.profession } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/recipes`)
      },
      error: (data) => {
        console.log(data.responseJSON.errors)
      }
    })
  }

  _renderProfessions() {
    return this.state.professions.map((profession) => {
      return <option value={profession.id} key={profession.id}>{profession.name[this.props.locale]}</option>
    })
  }

  render() {
    return (
      <div className="recipe_form">
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="recipe_name_en">{strings.nameEn}</label>
            <input required="required" placeholder={strings.nameLabelEn} className="form-control form-control-sm" type="text" id="recipe_name_en" value={this.state.name.en} onChange={(event) => this.setState({name: { en: event.target.value, ru: this.state.name.ru }})} />
          </div>
          <div className="form-group">
            <label htmlFor="recipe_name_ru">{strings.nameRu}</label>
            <input required="required" placeholder={strings.nameLabelRu} className="form-control form-control-sm" type="text" id="recipe_name_ru" value={this.state.name.ru} onChange={(event) => this.setState({name: { en: this.state.name.en, ru: event.target.value }})} />
          </div>
        </div>
        <div className="double_line">
          <div className="form-group">
            <label htmlFor="recipe_links_en">{strings.linkEn}</label>
            <input required="required" placeholder={strings.linkLabelEn} className="form-control form-control-sm" type="text" id="recipe_links_en" value={this.state.links.en} onChange={(event) => this.setState({links: { en: event.target.value, ru: this.state.links.ru }})} />
          </div>
          <div className="form-group">
            <label htmlFor="recipe_links_ru">{strings.linkRu}</label>
            <input required="required" placeholder={strings.linkLabelRu} className="form-control form-control-sm" type="text" id="recipe_links_ru" value={this.state.links.ru} onChange={(event) => this.setState({links: { en: this.state.links.en, ru: event.target.value }})} />
          </div>
        </div>
        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="recipe_profession_id">{strings.profession}</label>
              <select className="form-control form-control-sm" id="recipe_profession_id" onChange={(event) => this.setState({profession: event.target.value})} value={this.state.profession}>
                <option value="0"></option>
                {this._renderProfessions()}
              </select>
            </div>
            <div className="form-group">
              <label htmlFor="recipe_skill">{strings.skill}</label>
              <input required="required" placeholder={strings.skillLabel} className="form-control form-control-sm" type="number" id="recipe_skill" value={this.state.skill} onChange={(event) => this.setState({skill: event.target.value})} />
            </div>
          </div>
        </div>
        {this.state.recipeId === undefined &&
          <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
        }
        {this.state.recipeId !== undefined &&
          <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
        }
      </div>
    )
  }
}
