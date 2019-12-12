import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

export default class GuildBank extends React.Component {
  constructor() {
    super()
    this.state = {
      banks: []
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
        this.setState({banks: data.banks})
      }
    })
  }

  _checkLocale() {
    if (this.props.locale === 'en') return ''
    else return 'ru.'
  }

  _renderBanks() {
    return this.state.banks.map((bank, index) => {
      return (
        <div className="bank" key={index}>
          <h3>{bank.name}</h3>
          <p className="coins">{bank.coins}</p>
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
        {this._renderBanks()}
      </div>
    )
  }
}
