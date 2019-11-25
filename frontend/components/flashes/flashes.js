import "./flashes.scss";

const $ = require("jquery")

$('.content').on('click', '.flash-messages .alert button', function() {
  $(this).parent().hide()
})
