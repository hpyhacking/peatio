$(document).ready(function () {
  $('#sidebarCollapse').on('click', function () {
      $('.dashboard-sidebar').toggleClass('active');
      $('.dashboard-wrapper').toggleClass('sidebar-closed');
      $('.admin-header .toggle-sidebar-icon').toggleClass('fa-caret-right');
  });

  setSidebarHeight();
  initPerfectScrollbar();
});

$( window ).resize(function() {
  setSidebarHeight();
});


function setSidebarHeight() {
  var sidebarHeight = $('body').height() - $('.sidebar-header ').height();
  $('.sidebar-content').height(sidebarHeight);
};

function initPerfectScrollbar() {
    new PerfectScrollbar('.has-scrollbar', {
      wheelSpeed: 2,
      wheelPropagation: true,
      minScrollbarLength: 20
    });
};
