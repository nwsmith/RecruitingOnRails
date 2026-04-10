// Vanilla replacement for jquery_ujs's data-confirm support.
// Any <form data-confirm="..."> will prompt before submitting.
document.addEventListener('submit', function (event) {
  var message = event.target && event.target.dataset && event.target.dataset.confirm;
  if (message && !window.confirm(message)) {
    event.preventDefault();
  }
});
