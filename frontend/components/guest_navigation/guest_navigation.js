import "./guest_navigation.scss";

const $ = require("jquery")

$('.guest_content').on('click', '.navbar-toggler', function() {
  $('.guest_content .collapse').toggleClass('show')
})
