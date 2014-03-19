$(function(){
  Selectize.define('option_destroy', function() {
    var self = this;
    this.onOptionSelect = (function() {
      var original = self.onOptionSelect;
      return function(e) {
        $target = $(e.target);
        if ($target.hasClass('destroy-withdraw-address')) {
          $.ajax({
            url: '/withdraw_addresses/' + $target.data('addr-id'),
            type: 'DELETE'
            }).done(function(){
              self.load(self.settings.load);
              self.open();
            });
        } else {
          original.apply(this, arguments);
        }
      };
    })();
  });

  $('select#withdraw_address').selectize({
    plugins: ['option_destroy'],
    preload: 'focus',
    persist: false,
    createOnBlur: true,
    valueField: 'address',
    labelField: 'label',
    searchField: ['label', 'address'],
    create: true,
    render: {
      option: function(item, escape) {
        return '<div><div>' +
            '<span>' + escape(item.address) + '</span>' +
          '</div>' +
          '<div>' +
            '<span class="lead">' + escape(item.label) + '</span>' +
            '<a class="destroy-withdraw-address pull-right" href="javascript:void(0)" data-addr-id="' + item.id + '"> Delete </a>' +
          '</div></div>';
      }
    },
    onType: function(){},
    load: function(query, callback) {
      var self = this;
      if(!callback){
        callback = query;
        query = '';
      }
      $.ajax({
        url: '/withdraw_addresses?currency=' + $('input#withdraw_currency').val() + '&query=' + encodeURIComponent(query),
        type: 'GET',
        error: function() {
          callback();
        },
        success: function(res) {
          self.clearOptions();
          callback(res);
        }
      });
    },
    onItemAdd: function(value, $item) {
      $('form input#withdraw_address_label').val($item.text());
      $item.text(value);
    }
  });
});
