import React from "react"

const $ = require("jquery")

$.ajaxSetup({
  headers:
  { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
});

export default class LineUp extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      is_owner: props.is_owner,
      userCharacters: [],
      characters: [],
      selectedCharacterForSign: null
    }
  }

  componentWillMount() {
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

  onSignCharacter(option, event) {
    event.preventDefault()
    $.ajax({
      method: 'POST',
      url: this._defineSignUrl(option),
      data: { subscribe: { character_id: this.state.selectedCharacterForSign, event_id: this.props.event.id } },
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

  _defineSignUrl(value) {
    switch (value) {
      case 'subscribe':
        return `/subscribes.json`
        break
      case 'reject':
        return `/subscribes/reject.json`
        break
    }
  }

  onChangeCharacter(event) {
    this.setState({selectedCharacterForSign: event.target.value});
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
          <select className="form-control" onChange={this.onChangeCharacter.bind()} value={this.state.selectedCharacterForSign}>
            {characters}
          </select>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onSignCharacter.bind(this, 'subscribe')}>Subscribe</button>
          <button className="btn btn-primary btn-sm with_bottom_margin" onClick={this.onSignCharacter.bind(this, 'reject')}>Reject</button>
        </div>
      )
    }
  }

  _renderSigners(option) {
    const characters = this.state.characters.filter((character) => {
      return !character.subscribe_for_event.approved && ((option === 'signers' && character.subscribe_for_event.signed) || (option === 'rejecters' && !character.subscribe_for_event.signed))
    })

    return (
      <table className="table table-sm">
        <thead>
          <tr>
            <th>Name</th>
            <th>Level</th>
            <th>Race</th>
            <th>Class</th>
            <th>Guild</th>
          </tr>
        </thead>
        <tbody>
          {this._renderSignersInTable(characters)}
        </tbody>
      </table>
    )
  }

  _renderSignersInTable(characters) {
    if (characters.length === 0) {
      return (
        <tr><td>No data</td></tr>
      )
    } else {
      return characters.map((character) => {
        return (
          <tr className={character.character_class.en} key={character.id}>
            <td>{character.name}</td>
            <td>{character.level}</td>
            <td>{character.race.en}</td>
            <td>{character.character_class.en}</td>
            <td>{character.guild}</td>
          </tr>
        )
      })
    }
  }

  render() {
    return (
      <div className="line_up">
        <div className="approved">
          <div className="line_name">Raid LineUp</div>
        </div>
        <div className="signed">
          <div className="line_name">Signers</div>
          {this._renderSignBlock()}
          {this._renderSigners('signers')}
        </div>
        <div className="rejected">
          <div className="line_name">Rejected</div>
          {this._renderSigners('rejecters')}
        </div>
      </div>
    )
  }
}
