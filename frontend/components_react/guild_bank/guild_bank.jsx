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
      alert: '',
      bankRequests: [],
      categories: {},
      searchName: '',
      currentGameItemCategoryId: '0',
      currentGameItemSubcategoryId: '0'
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
        this.setState({banks: data.banks, itemsForRequest: itemsForRequest}, () => {
          this._getBankRequests()
        })
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

  _getBankRequests() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/bank_requests.json?access_token=${this.props.access_token}&guild_id=${this.props.guild_id}`,
      success: (data) => {
        this.setState({bankRequests: data.bank_requests}, () => {
          this._getGameItemCategories()
        })
      }
    })
  }

  _getGameItemCategories() {
    $.ajax({
      method: 'GET',
      url: `/api/v1/game_item_categories.json?access_token=${this.props.access_token}`,
      success: (data) => {
        this.setState({categories: data})
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
        let bankRequests = this.state.bankRequests
        bankRequests.push(data.bank_request)
        this.setState({alert: '', errors: [], currentGameItemId: '0', requestedAmount: 0, bankRequests: bankRequests})
      },
      error: (data) => {
        this.setState({errors: data.responseJSON.errors})
      }
    })
  }

  _onDeclineRequest(request) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/bank_requests/${request.id}/decline.json?access_token=${this.props.access_token}`,
      data: {},
      success: () => {
        let bankRequests = this.state.bankRequests
        const bankRequestIndex = bankRequests.indexOf(request)
        bankRequests.splice(bankRequestIndex, 1)
        this.setState({alert: '', errors: [], bankRequests: bankRequests})
      }
    })
  }

  _onApproveRequest(request) {
    $.ajax({
      method: 'POST',
      url: `/api/v1/bank_requests/${request.id}/approve.json?access_token=${this.props.access_token}`,
      data: { provided_amount: $(`.provided_amount_${request.id}`).val() },
      success: (data) => {
        let bankRequests = this.state.bankRequests
        const bankRequestIndex = bankRequests.indexOf(request)
        bankRequests.splice(bankRequestIndex, 1)
        const currentBank = this.state.banks.filter((bank) => {
          return bank.name === request.bank_name
        })[0]
        const currentBankIndex = this.state.banks.indexOf(currentBank)
        const currenctBankCell = this.state.banks[currentBankIndex].bank_cells.filter((bank_cell) => {
          return bank_cell.id === data.bank_cell.id
        })[0]
        const currentBankCellIndex = this.state.banks[currentBankIndex].bank_cells.indexOf(currenctBankCell)
        let banks = this.state.banks
        if (data.bank_cell.amount > 0) banks[currentBankIndex].bank_cells[currentBankCellIndex].amount = data.bank_cell.amount
        else banks[currentBankIndex].bank_cells.splice(currentBankCellIndex, 1)
        this.setState({alert: '', errors: [], bankRequests: bankRequests, banks: banks})
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

  _renderFilters() {
    return (
      <div className="filters">
        <div className="form-group">
          <label htmlFor="search_name">{strings.searchName}</label>
          <input className="form-control form-control-sm" id="search_name" onChange={(event) => this.setState({searchName: event.target.value})} value={this.state.searchName} />
        </div>
        <div className="row">
          <div className="col-md-6">
            <div className="form-group">
              <label htmlFor="game_item_category_id">{strings.gameItemCategory}</label>
              <select className="form-control form-control-sm" id="game_item_category_id" onChange={this._onChangeGameItemCategory.bind(this)} value={this.state.currentGameItemCategoryId}>
                <option value="0"></option>
                {this._renderGameItemCategories()}
              </select>
            </div>
          </div>
          <div className="col-md-6">
            <div className="form-group">
              <label htmlFor="game_item_subcategory_id">{strings.gameItemSubcategory}</label>
              <select className="form-control form-control-sm" id="game_item_subcategory_id" onChange={(event) => this.setState({currentGameItemSubcategoryId: event.target.value})} value={this.state.currentGameItemSubcategoryId} disabled={this.state.currentGameItemCategoryId === '0'}>
                <option value="0"></option>
                {this._renderGameItemSubcategories()}
              </select>
            </div>
          </div>
        </div>
      </div>
    )
  }

  _renderGameItemCategories() {
    return Object.entries(this.state.categories).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _renderGameItemSubcategories() {
    if (this.state.currentGameItemCategoryId === '0') return null
    return Object.entries(this.state.categories[this.state.currentGameItemCategoryId].subcategories).map(([key, value]) => {
      return <option value={key} key={key}>{value.name[this.props.locale]}</option>
    })
  }

  _onChangeGameItemCategory(event) {
    this.setState({currentGameItemCategoryId: event.target.value, currentGameItemSubcategoryId: '0'})
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
        <div className="bank row" key={index}>
          <div className="bank_info col-md-6">
            <h3>{bank.name}, <span className="bank_coins">{this._calcCoins(bank.coins)}</span></h3>
            <div className="bank_cells">
              {this._renderBankCells(bank.bank_cells)}
            </div>
          </div>
          <div className="bank_requests col-md-6">
            {this._renderBankRequests(bank.name)}
          </div>
        </div>
      )
    })
  }

  _renderBankCells(bankCells) {
    return bankCells.map((bankCell, index) => {
      return (
        <div className={this._defineFilterOn(bankCell)} key={index}>
          {bankCell.game_item !== null &&
            <a href={`https://${this._checkLocale()}classic.wowhead.com/item=${bankCell.item_uid}`} onClick={(event) => event.preventDefault()} aria-label="Item">
              <img src={`https://wow.zamimg.com/images/wow/icons/large/${bankCell.game_item.icon_name}.jpg`} alt="" />
            </a>
          }
          <span className="bank_cell_amount">{bankCell.amount}</span>
        </div>
      )
    })
  }

  _defineFilterOn(bankCell) {
    let result = "bank_cell"
    if (bankCell.game_item === null) return result
    if (this.state.searchName !== '' && bankCell.game_item.name.en.toLowerCase().indexOf(this.state.searchName.toLowerCase()) === -1 && bankCell.game_item.name.ru.toLowerCase().indexOf(this.state.searchName.toLowerCase()) === -1) return result + " hidden"

    if (this.state.currentGameItemCategoryId === '0') return result

    if (this.state.currentGameItemSubcategoryId === '0') {
      if (bankCell.game_item.category !== parseInt(this.state.currentGameItemCategoryId)) result += " hidden"
    } else {
      if (bankCell.game_item.category !== parseInt(this.state.currentGameItemCategoryId) || bankCell.game_item.subcategory !== parseInt(this.state.currentGameItemSubcategoryId)) result += " hidden"
    }
    return result
  }

  _renderBankRequests(bankName) {
    const filtered = this.state.bankRequests.filter((request) => {
      return request.bank_name === bankName
    })
    if (filtered.length === 0) return false
    return (
      <div>
        <h4>{strings.requestsTitle}</h4>
        <table className="table table-sm">
          <thead>
            <tr>
              <th>{strings.name}</th>
              <th>{strings.itemName}</th>
              <th>{strings.amount}</th>
              <th>
                {this.props.banker && strings.give}
              </th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this._renderRequests(filtered)}
          </tbody>
        </table>
      </div>
    )
  }

  _renderRequests(filtered) {
    return filtered.map((request) => {
      return (
        <tr key={request.id}>
          <td>{request.character_name}</td>
          <td>{request.game_item_name[this.props.locale]}</td>
          <td>{request.requested_amount}</td>
          <td>
            {this.props.banker &&
              <input className={`form-control form-control-sm provided_amount provided_amount_${request.id}`} defaultValue={request.requested_amount} />
            }
          </td>
          <td>
            {this.props.banker && <button className="btn btn-icon btn-add" onClick={this._onApproveRequest.bind(this, request)} aria-label="Add button"></button>}
            {this.props.banker && <button className="btn btn-icon btn-delete" onClick={this._onDeclineRequest.bind(this, request)} aria-label="Delete button"></button>}
          </td>
        </tr>
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
        <div className="row">
          <div className="col-md-6">
            <h4>{strings.filters}</h4>
            {this._renderFilters()}
          </div>
          <div className="col-md-6">
            <h4>{strings.newRequestForm}</h4>
            {this._renderBankRequestForm()}
          </div>
        </div>
        {this._renderBanks()}
      </div>
    )
  }
}
