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

export default class RecipeForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      name: { en: '', ru: '' },
      links: { en: '', ru: '' },
      effectName: { en: '', ru: '' },
      effectLinks: { en: '', ru: '' },
      skill: 300,
      professions: [],
      profession: 0,
      errors: []
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
        this.setState({name: recipe.name, links: recipe.links, effectName: recipe.effect_name, effectLinks: recipe.effect_links, skill: recipe.skill, profession: recipe.profession_id})
      }
    })
  }

  _onCreate() {
    const state = this.state
    let url = `/api/v1/recipes.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'POST',
      url: url,
      data: { recipe: { name: state.name, links: state.links, effect_name: state.effectName, effect_links: state.effectLinks, skill: state.skill, profession_id: state.profession } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/recipes`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onUpdate() {
    const state = this.state
    let url = `/api/v1/recipes/${this.props.recipe_id}.json?access_token=${this.props.access_token}`
    if (this.props.locale !== 'en') url += `&locale=${this.props.locale}`
    $.ajax({
      method: 'PATCH',
      url: url,
      data: { recipe: { name: state.name, links: state.links, effect_name: state.effectName, effect_links: state.effectLinks, skill: state.skill, profession_id: state.profession } },
      success: () => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/recipes`)
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _renderProfessions() {
    return this.state.professions.map((profession) => {
      return <option value={profession.id} key={profession.id}>{profession.name[this.props.locale]}</option>
    })
  }

  _renderSubmitButton() {
    if (this.state.recipeId === undefined) return <input type="submit" name="commit" value={strings.create} className="btn btn-primary btn-sm" onClick={this._onCreate.bind(this)} />
    return <input type="submit" name="commit" value={strings.update} className="btn btn-primary btn-sm" onClick={this._onUpdate.bind(this)} />
  }

  _renderFormLabel() {
    if (this.state.recipeId === undefined) return <h2>{strings.createLabel}</h2>
    return <h2>{strings.updateLabel}</h2>
  }

  render() {
    return (
      <div className="recipe_form">
        {this._renderFormLabel()}
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        <div className="double_line">
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
        </div>

        <div className="double_line">
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="recipe_effect_name_en">{strings.effectNameEn}</label>
              <input required="required" placeholder={strings.effectNameLabelEn} className="form-control form-control-sm" type="text" id="recipe_effect_name_en" value={this.state.effectName.en} onChange={(event) => this.setState({effectName: { en: event.target.value, ru: this.state.effectName.ru }})} />
            </div>
            <div className="form-group">
              <label htmlFor="recipe_effect_name_ru">{strings.effectNameRu}</label>
              <input required="required" placeholder={strings.effectNameLabelRu} className="form-control form-control-sm" type="text" id="recipe_effect_name_ru" value={this.state.effectName.ru} onChange={(event) => this.setState({effectName: { en: this.state.effectName.en, ru: event.target.value }})} />
            </div>
          </div>
          <div className="double_line">
            <div className="form-group">
              <label htmlFor="recipe_effect_links_en">{strings.effectLinkEn}</label>
              <input required="required" placeholder={strings.effectLinkLabelEn} className="form-control form-control-sm" type="text" id="recipe_effect_links_en" value={this.state.effectLinks.en} onChange={(event) => this.setState({effectLinks: { en: event.target.value, ru: this.state.effectLinks.ru }})} />
            </div>
            <div className="form-group">
              <label htmlFor="recipe_effect_links_ru">{strings.effectLinkRu}</label>
              <input required="required" placeholder={strings.effectLinkLabelRu} className="form-control form-control-sm" type="text" id="recipe_effect_links_ru" value={this.state.effectLinks.ru} onChange={(event) => this.setState({effectLinks: { en: this.state.effectLinks.en, ru: event.target.value }})} />
            </div>
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
        {this._renderSubmitButton()}
      </div>
    )
  }
}
