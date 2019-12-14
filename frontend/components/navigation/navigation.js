import "./navigation.scss";

const $ = require("jquery")
import Cookies from 'js-cookie'

$('.content').on('click', '.navbar-toggler.small-icon', function() {
  $('.content .collapse').toggleClass('show')
})

$('.content').on('click', '.navbar-toggler.shorter-icon', function() {
  const guildHallCollapsedMenu = Cookies.get('guildHallCollapsedMenu')
  if (guildHallCollapsedMenu === undefined || guildHallCollapsedMenu === '0') {
    Cookies.set('guildHallCollapsedMenu', '1', { expires: 365 })
  } else {
    Cookies.set('guildHallCollapsedMenu', '0', { expires: 365 })
  }
  $('.content .navigation').toggleClass('collapsed')
})
