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

