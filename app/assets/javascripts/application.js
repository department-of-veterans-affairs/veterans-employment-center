// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require iframeResizer.contentWindow.mod
//= require jquery.dataTables
//= require jquery.maskedinput
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery-ui-1.10.4.custom.min
//= require typeahead.bundle
//= require typeahead.jquery
//= require bloodhound
//= require angular
//= require underscore
//= require angular-typeahead
//= require angular-cookies
//= require va_common_main
//= require_tree .

var Application = {
  init: function() {
    // For each field with a data mask, apply it
    $("input[data-mask]").each(function() {
      var item = $(this)
      item.mask(item.attr("data-mask"));
    })
  }
};

$(function() {
  Application.init();
});