// invisible bot protection behavior token updater
(function() {
  var tokenParam = '_invisible_token';
  
  function updateToken() {
    var tokenField = document.querySelector('input[name="' + tokenParam + '"]');
    if (tokenField) {
      tokenField.value = Date.now() / 1000;
    }
  }
  
  document.addEventListener('keydown', updateToken);
  document.addEventListener('keypress', updateToken);
  document.addEventListener('focus', updateToken, true);
  document.addEventListener('click', updateToken, true);
})();

