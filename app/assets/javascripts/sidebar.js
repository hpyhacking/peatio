$(document).ready(function () {

    $('#sidebarCollapse').on('click', function () {
        $('#sidebar').toggleClass('active');
        $('.wrapper').toggleClass('sidebar-closed');
        $('.admin-header .toggle-sidebar-icon').toggleClass('fa-caret-right');
    });

});