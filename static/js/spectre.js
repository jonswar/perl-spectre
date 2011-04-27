// Define console for browsers without it in case we leave in any console.* statements
// http://digitalize.ca/2010/04/javascript-tip-save-me-from-console-log-errors/
//
if (typeof(console) === 'undefined') {
    window.console = {};
    console.log = console.error = console.info = console.debug = console.warn = console.trace = console.dir = console.dirxml = console.group = console.groupEnd = console.time = console.timeEnd = console.assert = console.profile = function() {};
}

$(document).ajaxError(function(e, xhr, settings, exception) {
  alert('ajax error in: ' + settings.url);
});

var sp = new Object();

sp.toggleResult = function (id) {
    $('#result' + id).toggle();
    $('#triangle_right' + id).toggle();
    $('#triangle_down' + id).toggle();
}

sp.openAllResults = function () {
    $('.single_result').show();
    $('.triangle_down').show();
    $('.triangle_right').hide();
    $('#open_all_results').hide();
    $('#close_all_results').show();
}

sp.closeAllResults = function () {
    $('.single_result').hide();
    $('.triangle_down').hide();
    $('.triangle_right').show();
    $('#open_all_results').show();
    $('#close_all_results').hide();
}
