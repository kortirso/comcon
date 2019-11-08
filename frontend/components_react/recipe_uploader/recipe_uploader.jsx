import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class RecipeUploader extends React.Component {
  constructor() {
    super()
    this.state = {
      value: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
  }

  _onUploadRecipes(event) {
    event.preventDefault()
    $.ajax({
      method: 'POST',
      url: `/api/v1/characters/${this.props.character_id}/upload_recipes.json?access_token=${this.props.access_token}`,
      data: { profession_id: this.props.profession_id, value: this.state.value },
      success: (data) => {
        window.location.replace(`${this.props.locale === 'en' ? '' : ('/' + this.props.locale)}/characters/${this.props.character_id}/recipes`)
      },
      error: () => {
        this.setState({value: 'Recipes are not uploaded'})
      }
    })
  }

  render() {
    return (
      <div className="form-group">
        <textarea type="text" className="form-control form-control-sm" placeholder={strings.massLabel} value={this.state.value} onChange={(event) => this.setState({value: event.target.value})} />
        <button className="btn btn-primary btn-sm with_top_margin" onClick={this._onUploadRecipes.bind(this)} disabled={this.state.value === ''}>{strings.upload}</button>
      </div>
    )
  }
}
