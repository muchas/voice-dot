var custom_replaces = {};

console.log('test');

chrome.storage.local.get('custom_replaces', function(items) {
  var replaces = items['custom_replaces'] || {};
  for (var key in replaces) {
    addToArray(key, replaces[key]);
  }
});

$('#addNewReplace').click(function() {
  var keyword = $('#keyword').val();
  var replaceWord = $('#replaceWord').val();

  addToArray(keyword, replaceWord);
});

function addToArray(keyword, replaceWord) {
  if (custom_replaces[keyword]) {
    delFromArray(keyword);
  }

  custom_replaces[keyword] = replaceWord;
  chrome.storage.local.set({ 'custom_replaces': custom_replaces });

  var $el = $('<tr id="' + keyword + '"><td>' + keyword + '</td><td>' + replaceWord + '</td><td><a class="delLink" id="' + keyword + '">del</a></td></tr>');
  $el.insertBefore('tr:last-child');
  $('.delLink').click(function() {
    delFromArray($(this).attr('id'));
  });
}

function delFromArray(keyword) {
  delete custom_replaces[keyword];
  chrome.storage.local.set({ 'custom_replaces': custom_replaces });
  $('table tr#' + keyword).remove();
}
