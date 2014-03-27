$(function(){
  Selectize.define('option_destroy', function() {
    var self = this;
    this.onOptionSelect = (function() {
      var original = self.onOptionSelect;
      return function(e) {
        $target = $(e.target);
        if ($target.hasClass('destroy-withdraw-address')) {
          $.ajax({
            url: '/fund_sources/' + $target.data('addr-id'),
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

  $('select#withdraw_fund_uid').selectize({
    plugins: ['option_destroy'],
    preload: true,
    createOnBlur: true,
    valueField: 'address',
    labelField: 'label',
    searchField: ['label', 'address'],
    create: function(input){
      return {
        address: input,
        label: 'label'
      }
    },
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
    load: function(query, callback) {
      var self = this;
      if(!callback){
        callback = query;
        query = '';
      }
      $.ajax({
        url: '/fund_sources?channel_id=' + $('input#withdraw_channel_id').val() + '&query=' + encodeURIComponent(query),
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
      $('form input#fund_source_label').val($item.text());
      $item.text(value);
    }
  });
});
