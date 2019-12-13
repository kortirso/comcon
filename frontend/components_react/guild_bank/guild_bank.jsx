import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

import ErrorView from '../error_view/error_view'
import Alert from '../alert/alert'

let strings = new LocalizedStrings(I18nData)

export default class GuildBank extends React.Component {
  constructor() {
    super()
    this.state = {
      banks: [],
      itemsForRequest: [],
      currentItems: [],
      currentCharacterId: '0',
      currenBankId: '0',
      currentGameItemId: '0',
      requestedAmount: 0,
      errors: [],
      alert: ''
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getBanks()
  }

  _getBanks() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/guilds/${this.props.guild_id}/bank.json?access_token=${this.props.access_token}`,
      success: (data) => {
        const itemsForRequest = data.banks.map((bank) => {
          return {
            id: bank.id,
            name: bank.name,
            game_items: this._modifyGameItems(bank.bank_cells)
          }
        })
        this.setState({banks: data.banks, itemsForRequest: itemsForRequest})
      }
    })
  }

  _makeRequest() {
    const state = this.state
    $.ajax({
      method: 'POST',
      url: `/api/v1/bank_requests.json?access_token=${this.props.access_token}`,
      data: { bank_request: { bank_id: state.currentBankId, character_id: state.currentCharacterId, game_item_id: state.currentGameItemId, requested_amount: state.requestedAmount } },
      success: (data) => {
        this.setState({alert: 'Bank request is created', errors: [], currentGameItemId: '0', requestedAmount: 0})
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _modifyGameItems(bankCells) {
    return bankCells.map((bankCell) => {
      if (bankCell.game_item === null) return null
      return {
        id: bankCell.game_item.id,
        name: bankCell.game_item.name,
        amount: bankCell.amount
      }
    })
  }

  _checkLocale() {
    if (this.props.locale === 'en') return ''
    else return 'ru.'
  }

  _calcCoins(coins) {
    const gold = parseInt(coins / 10000)
    coins -= gold * 10000
    const silver = parseInt(coins / 100)
    coins -= silver * 100
    return `g${gold} s${silver} c${coins}`
  }

  _renderBankRequestForm() {
    return (
      <div className="new_bank_request">
        <div className="fields">
          <div className="form-group">
            <label htmlFor="character_id">{strings.character}</label>
            <select className="form-control form-control-sm" id="character_id" onChange={(event) => this.setState({currentCharacterId: event.target.value})} value={this.state.currentCharacterId}>
              <option value="0"></option>
              {this._renderUserCharacters()}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="bank_id">{strings.bank}</label>
            <select className="form-control form-control-sm" id="bank_id" onChange={this._onBankChange.bind(this)} value={this.state.currentBankId}>
              <option value="0"></option>
              {this._renderBankWithItems()}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="game_item_id">{strings.items}</label>
            <select className="form-control form-control-sm" id="game_item_id" onChange={this._onItemChange.bind(this)} value={this.state.currentGameItemId}>
              <option value="0"></option>
              {this._renderCurrentItems()}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="requested_amount">{strings.requestedAmount}</label>
            <input className="form-control form-control-sm" id="requested_amount" onChange={(event) => this.setState({requestedAmount: event.target.value})} value={this.state.requestedAmount} />
          </div>
        </div>
        <button type="button" className="btn btn-primary btn-sm" onClick={() => this._makeRequest()} disabled={this.state.currentCharacterId === '0' || this.state.currentBankId === '0' || this.state.currentGameItemId === '0'}>{strings.start}</button>
      </div>
    )
  }

  _renderUserCharacters() {
    return this.props.user_characters.map((character) => {
      return <option value={character[0]} key={character[0]}>{character[1]}</option>
    })
  }

  _renderBankWithItems() {
    return this.state.itemsForRequest.map((item) => {
      return <option value={item.id} key={item.id}>{item.name}</option>
    })
  }

  _onBankChange(event) {
    this.setState({currentBankId: event.target.value}, () => {
      const currentBank = this.state.itemsForRequest.filter((bank) => {
        return bank.id === parseInt(this.state.currentBankId)
      })
      if (currentBank.length === 1) this.setState({currentItems: currentBank[0].game_items})
      else this.setState({currentItems: [], requestedAmount: 0})
    })
  }

  _renderCurrentItems() {
    return this.state.currentItems.map((item) => {
      return <option value={item.id} key={item.id}>{item.name[this.props.locale]}</option>
    })
  }

  _onItemChange(event) {
    this.setState({currentGameItemId: event.target.value}, () => {
      const currentItem = this.state.currentItems.filter((item) => {
        return item.id === parseInt(this.state.currentGameItemId)
      })
      if (currentItem.length === 1) this.setState({requestedAmount: currentItem[0].amount})
      else this.setState({requestedAmount: 0})
    })
  }

  _renderBanks() {
    return this.state.banks.map((bank, index) => {
      return (
        <div className="bank" key={index}>
          <h3>{bank.name}, <span className="bank_coins">{this._calcCoins(bank.coins)}</span></h3>
          <div className="bank_cells">
            {this._renderBankCells(bank.bank_cells)}
          </div>
        </div>
      )
    })
  }

  _renderBankCells(bankCells) {
    return bankCells.map((bankCell, index) => {
      return (
        <div className="bank_cell" key={index}>
          {bankCell.game_item !== null &&
            <a href={`https://${this._checkLocale()}classic.wowhead.com/item=${bankCell.item_uid}`} onClick={(event) => event.preventDefault()}>
              <img src={`https://wow.zamimg.com/images/wow/icons/large/${bankCell.game_item.icon_name}.jpg`} alt="" />
            </a>
          }
          <span className="bank_cell_amount">{bankCell.amount}</span>
        </div>
      )
    })
  }

  render() {
    return (
      <div className="banks">
        {this.state.errors.length > 0 &&
          <ErrorView errors={this.state.errors} />
        }
        {this.state.alert !== '' &&
          <Alert type="success" value={this.state.alert} />
        }
        <h4>{strings.newRequestForm}</h4>
        {this._renderBankRequestForm()}
        {this._renderBanks()}
      </div>
    )
  }
}
