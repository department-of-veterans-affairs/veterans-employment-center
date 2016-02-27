$(document).ready(function(){

  $(document).on('click', 'a.next_page_link, a.prev_page_link' ,  function(e) {
    var _self = this;
    $.ajax({
      url:_self.href,
      type:"get",
      dataType: 'html'
    }).done(function( html ){
      $('.search-results').replaceWith(html );
      $(window).scrollTop($('.search-results').offset().top);
    });
    e.preventDefault();
    e.stopPropagation();

  });
});

