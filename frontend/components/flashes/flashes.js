import "./flashes.scss";

const $ = require("jquery")

$('.guest_content').on('click', '.flash-messages .alert button', function() {
  $(this).parent().hide()
})

$('.content').on('click', '.flash-messages .alert button', function() {
  $(this).parent().hide()
})
