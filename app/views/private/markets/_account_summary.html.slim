li#account_summary.dropdown
  a.dropdown-toggle href="#" data-toggle="dropdown"
    span#total_assets data-title=t('.title')
  .dropdown-menu.text-right
    p.text-right
      ul.list-inline.text-right
    table.table: tbody
      - current_user.accounts.each do |account|
        - next unless account.currency_obj.try(:visible)
        tr class='#{account.currency} #{@market.scope?(account) ? '' : 'hide'}'
          td.account-symbol.col-xs-6.text-center
            img src="/icon-#{account.currency}.png" alt="#{account.currency_obj.code_text}"
            br
            span = account.currency_obj.code_text
          td.account-balance.col-xs-18.text-right
            span.amount data-title='#{t('.amount')}' = account.amount
            br
            span.locked data-title='#{t('.locked')}' = account.locked
      tr
        td.text-center colspan=2
          a.view_all_accounts data-hide-text='#{t('.hide_all_accounts')}' data-show-text='#{t('.view_all_accounts')}' href='#' = t('.view_all_accounts')

