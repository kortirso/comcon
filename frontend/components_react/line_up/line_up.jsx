import React from "react"
import LocalizedStrings from 'react-localization'
import I18nData from './i18n_data.json'

const $ = require("jquery")

let strings = new LocalizedStrings(I18nData)

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class LineUp extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      isOwner: props.is_owner,
      currentUserId: props.current_user_id,
      userCharacters: [],
      characters: [],
      selectedCharacterForSign: null
    }
  }

  componentWillMount() {
    strings.setLanguage(this.props.locale)
    this._getEventsSubscribes()
  }

  _filterCharacters(characters) {
    return characters.filter((character) => {
      return character.subscribe_for_event === null
    })
  }

  _getEventsSubscribes() {
    const _this = this
    $.ajax({
      method: 'GET',
      url: `/events/${this.props.event.slug}.json`,
      success: (data) => {
        const userCharacters = this._filterCharacters(data.user_characters)
        this.setState({
          userCharacters: userCharacters,
          characters: data.characters,
          selectedCharacterForSign: userCharacters.length > 0 ? userCharacters[0].id : null
        })
      }
    })
  }

  onCreateSubscribe(status, event) {
    event.preventDefault()
    $.ajax({
      method: 'POST',
      url: `/subscribes.json`,
      data: { subscribe: { character_id: this.state.selectedCharacterForSign, event_id: this.props.event.id, status: status } },
      success: (data) => {
        const userCharacters = this._filterCharacters(data.user_characters)
        this.setState({
          userCharacters: userCharacters,
          characters: data.characters,
          selectedCharacterForSign: userCharacters.length > 0 ? userCharacters[0].id : null
        })
      }
    })
  }

  onUpdateSubscribe(subscribeId, status, event) {
    event.preventDefault()
    $.ajax({
      method: 'PATCH',
      url: `/subscribes/${subscribeId}.json`,
      data: { subscribe: { status: status } },
      success: (data) => {
        const userCharacters = this._filterCharacters(data.user_characters)
        this.setState({
          userCharacters: userCharacters,
          characters: data.characters,
          selectedCharacterForSign: userCharacters.length > 0 ? userCharacters[0].id : null
        })
      }
    })
  }

  _renderSignBlock() {
    if (this.state.userCharacters.length === 0) return false
    else {
      let characters = this.state.userCharacters.map((character) => {
        return <option value={character.id} key={character.id}>{character.name}</option>
      })
      return (
        <div className="user_signers">
          <p>You can sign your character for this event</p>
          <select className="form-control" onChange={this._onChangeCharacter.bind()} value={this.state.selectedCharacterForSign}>
            {characters}
          </select>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'signed')}>Subscribe</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'unknown')}>Unknown</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onCreateSubscribe.bind(this, 'rejected')}>Reject</button>
        </div>
      )
    }
  }

  _onChangeCharacter(event) {
    this.setState({selectedCharacterForSign: event.target.value})
  }

  _renderSigners(option) {
    const characters = this.state.characters.filter((character) => {
      return (option === 'signers' && character.subscribe_for_event.status === 'signed') || (option === 'rejecters' && character.subscribe_for_event.status === 'rejected') || (option === 'unknown' && character.subscribe_for_event.status === 'unknown')
    })

    return (
      <table className="table table-sm">
        {this._renderTableHead()}
        <tbody>
          {this._renderSignersInTable(characters, option)}
        </tbody>
      </table>
    )
  }

  _renderSignersInTable(characters, option) {
    if (characters.length === 0) {
      return (
        <tr><td>{strings.noData}</td></tr>
      )
    } else {
      return characters.map((character) => {
        return (
          <tr className={character.character_class.en} key={character.id}>
            <td><div className="character_name">{character.name}{this._renderRoleIcons(character, option)}</div></td>
            <td>{character.level}</td>
            <td>{character.race[this.props.locale]}</td>
            <td>{character.character_class[this.props.locale]}</td>
            <td>{character.guild}</td>
            <td>
              <div className="buttons">
                {this.state.isOwner && option === 'signers' && this._renderAdminButton(character.subscribe_for_event.id, 'approved', strings.approve)}
                {this.state.currentUserId === character.user_id && this._renderUserButton(character.subscribe_for_event.id, option)}
              </div>
            </td>
          </tr>
        )
      })
    }
  }

  _renderUserButton(subscribeId, option) {
    let buttons = []
    if (option !== 'signers') buttons.push(<button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, 'signed')}>{strings.sign}</button>)
    if (option !== 'rejecters') buttons.push(<button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, 'rejected')}>{strings.reject}</button>)
    if (option !== 'unknown') buttons.push(<button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, 'unknown')}>{strings.unknown}</button>)
    return <div className="user_buttons">{buttons}</div>
  }

  _renderAdminButton(subscribeId, action, button) {
    return <button className="btn btn-light btn-sm with_bottom_margin" onClick={this.onUpdateSubscribe.bind(this, subscribeId, action)}>{button}</button>
  }

  _renderRoleIcons(character, option) {
    if (option !== 'signers') return false
    else return <div className="role_icons"><div className={`role_icon ${character.main_role.en}`}></div></div>
  }

  _renderLineUp() {
    const characters = this.state.characters.filter((character) => {
      return character.subscribe_for_event.status === 'approved'
    })

    if (characters.length === 0) return false
    else {
      let lineUp = []
      const roles = [strings.tank, strings.healer, strings.melee, strings.ranged]
      roles.forEach((role, index) => {
        const chars = characters.filter((character) => {
          return character.main_role[this.props.locale] === role
        })

        lineUp.push(<tr key={index}><td colSpan="6" className="role_name">{role}</td></tr>)
        if (chars.length === 0) lineUp.push(<tr key={- index}><td colSpan="6">{strings.noData}</td></tr>)
        else {
          chars.forEach((character) => {
            lineUp.push(
              <tr className={character.character_class.en} key={character.name}>
                <td><div className="character_name">{character.name}</div></td>
                <td>{character.level}</td>
                <td>{character.race[this.props.locale]}</td>
                <td>{character.character_class[this.props.locale]}</td>
                <td>{character.guild}</td>
                <td>
                  <div className="buttons">
                    {this.state.isOwner && this._renderAdminButton(character.subscribe_for_event.id, 'signed', strings.remove)}
                    {this.state.currentUserId === character.user_id && this._renderUserButton(character.subscribe_for_event.id, 'signers')}
                  </div>
                </td>
              </tr>
            )
          })
        }
      })

      return (
        <table className="table table-sm">
          {this._renderTableHead()}
          <tbody>
            {lineUp}
          </tbody>
        </table>
      )
    }
  }

  _renderTableHead() {
    return (
      <thead>
        <tr>
          <th>{strings.name}</th>
          <th>{strings.level}</th>
          <th>{strings.race}</th>
          <th>{strings.characterClass}</th>
          <th>{strings.guild}</th>
          <th></th>
        </tr>
      </thead>
    )
  }

  render() {
    return (
      <div className="line_up">
        <div className="approved">
          <div className="line_name">{strings.lineUp}</div>
          {this._renderLineUp()}
        </div>
        <div className="signed">
          <div className="line_name">{strings.signers}</div>
          {this._renderSignBlock()}
          {this._renderSigners('signers')}
        </div>
        <div className="unknown">
          <div className="line_name">{strings.unknown}</div>
          {this._renderSigners('unknown')}
        </div>
        <div className="rejected">
          <div className="line_name">{strings.rejected}</div>
          {this._renderSigners('rejecters')}
        </div>
      </div>
    )
  }
}
