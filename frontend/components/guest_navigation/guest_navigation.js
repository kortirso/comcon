import "./guest_navigation.scss";

const $ = require("jquery")

$('.content').on('click', '.navbar-toggler', function() {
  $('#navbarSupportedContent').toggleClass('show')
})
