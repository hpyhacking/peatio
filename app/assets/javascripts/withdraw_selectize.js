$(function(){
  Selectize.define('option_destroy', function() {
    var self = this;
    this.onOptionSelect = (function() {
      var original = self.onOptionSelect;
      return function(e) {
        $target = $(e.target);
        if ($target.hasClass('glyphicon-trash')) {
          $.ajax({
            url: '/fund_sources/' + $target.parent().data('addr-id'),
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

  var sels = $('select#withdraw_fund_extra').selectize();
  $('select#withdraw_fund_uid').selectize({
    plugins: ['option_destroy'],
    preload: true,
    persist: false,
    createOnBlur: true,
    valueField: 'uid',
    labelField: 'extra',
    searchField: ['uid', 'extra'],
    create: function(input){
      var extra = '';
      if(sels[0]){
        extra = sels[0].selectize.getValue() || extra;
      }

      return {
        uid: input,
        extra: extra
      }
    },
    render: {
      option: function(item, escape) {
        return '<div><div>' +
            '<span>' + escape(item.uid) + '</span>' +
          '</div>' +
          '<div>' +
            '<span class="">' + escape(gon.banks[item.extra]) + '</span>' +
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
      if(query.length < 4){
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
      }
    },
    onItemAdd: function(value, $item) {
      var extra = $item.text();
      $item.text(value);
      $('form input#withdraw_fund_extra').val(extra);

      if(sels[0]){
        var index = extra.indexOf(' ');
        if(index >= 0){
          $('form input#withdraw_subbranch').val(extra.slice(index+1));
          extra = extra.slice(0, index);
        }
        sels[0].selectize.setValue(extra);
      }
    }
  });
});
