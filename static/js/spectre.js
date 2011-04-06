// Define console for browsers without it in case we leave in any console.* statements
// http://digitalize.ca/2010/04/javascript-tip-save-me-from-console-log-errors/
//
if (typeof(console) === 'undefined') {
    window.console = {};
    console.log = console.error = console.info = console.debug = console.warn = console.trace = console.dir = console.dirxml = console.group = console.groupEnd = console.time = console.timeEnd = console.assert = console.profile = function() {};
}

var $j = jQuery.noConflict();
$j(document).ajaxError(function(e, xhr, settings, exception) {
  alert('ajax error in: ' + settings.url);
});

var sp = new Object();

sp.toggleOkRows = function () {
    $j('.toggle_ok').toggle();
}

sp.toggleOkFiles = function () {
    $j('.toggle_ok_files').toggle();
}

sp.toggleResult = function (id) {
    $j('#result' + id).toggle();
    $j('#triangle_right' + id).toggle();
    $j('#triangle_down' + id).toggle();
}

sp.openAllResults = function () {
    $j('.single_result').show();
    $j('.triangle_down').show();
    $j('.triangle_right').hide();
    $j('#open_all_results').hide();
    $j('#close_all_results').show();
}

sp.closeAllResults = function () {
    $j('.single_result').hide();
    $j('.triangle_down').hide();
    $j('.triangle_right').show();
    $j('#open_all_results').show();
    $j('#close_all_results').hide();
}
