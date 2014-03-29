$(function(){
  Selectize.define('option_destroy', function() {
    var self = this;
    this.onOptionSelect = (function() {
      var original = self.onOptionSelect;
      return function(e) {
        $target = $(e.target);
        if ($target.hasClass('destroy-fund-source')) {
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

  var bank_name_selectize = $('select#withdraw_bank_name').selectize();
  $('select#withdraw_fund_uid').selectize({
    plugins: ['option_destroy'],
    preload: true,
    createOnBlur: true,
    valueField: 'uid',
    labelField: 'extra',
    searchField: ['uid', 'extra'],
    create: function(input){
      return {
        uid: input,
        extra: 'label'
      }
    },
    render: {
      option: function(item, escape) {
        return '<div><div>' +
            '<span>' + escape(item.uid) + '</span>' +
          '</div>' +
          '<div>' +
            '<span class="">' + escape(item.extra) + '</span>' +
            '<a class="destroy-fund-source pull-right" href="javascript:void(0)" data-addr-id="' + item.id + '">' +
              '<span class="glyphicon glyphicon-trash"></span>' +
            '</a>' +
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
      var extra = $item.text();
      $item.text(value);
      $('form input#withdraw_fund_extra').val(extra);

      var index = extra.indexOf(' ');
      if(index == -1){
        var subbranch = extra;
      } else {
        var bank_name = extra.slice(0, index);
        var subbranch = extra.slice(index+1);

        bank_name_selectize[0].selectize.setValue(bank_name);
        $('form input#withdraw_subbranch').val(subbranch);
      }
    }
  });
});
