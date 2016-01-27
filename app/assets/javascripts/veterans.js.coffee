# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    content = $($(this).data('fields').replace(regexp, time))
    content.find("input[data-mask]").each(->
            item = $(this)
            item.mask(item.attr("data-mask"))
    )
    $(this).before(content)
    event.preventDefault()
