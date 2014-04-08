module ApplicationHelper
  def document_to(key: nil, title: nil, &block)
    if title
      link_to(title, '', :data => {:remote => "#{main_app.document_path(key)}", :toggle => "modal", :target => '#document_modal'})
    elsif block
      link_to('', :data => {:remote => "#{main_app.document_path(key)}", :toggle => "modal", :target => '#document_modal'}, &block)
    end
  end

  def detail_section_tag(title)
    content_tag('span', title, :class => 'detail-section') + \
    tag('hr')
  end

  def detail_tag(obj, title: 'detail', field: nil, cls: '', clip: nil)
    if field.present?
      field = field.to_s
      val = obj.instance_eval(field)
      display = val || 'N/A'
      content_tag('span', :class => "#{field} detail-item #{val ? nil : 'empty'}" + cls, :data => {:title => obj.class.han(field)}) do
        if clip and val
          content_tag('i', display, :class => 'fa fa-copy', :data => {:'clipboard-text' => display})
        else
          content_tag('span', display)
        end
      end
    else
      content_tag('span', obj, :class => 'detail-item ' + cls, :data => {title: title})
    end
  end

  def cs_link
    link_to t('helpers.action.customer_service'), "javascript:void(0);", :onclick => "olark('api.box.expand')"
  end

  def check_active(klass)
    if klass.is_a? String
      return 'active' unless (controller.controller_path.exclude?(klass.singularize))
    else
      return 'active' if (klass.model_name.singular == controller.controller_name.singularize)
    end
  end

  def breadcrumbs
    content_tag 'ol', class: 'breadcrumb' do
      breadcrumb(controller_path.split('/'), []).reverse.join.html_safe
    end
  end

  def breadcrumb(paths, result)
    return result if paths.empty?
    r = content_tag :li, class: "#{result.empty? ? 'active' : nil}" do
      if result.empty?
        I18n.t("breadcrumbs.#{paths.join('/')}", default: 'DEFAULT')
      else
        content_tag :a, href: '#' do
          I18n.t("breadcrumbs.#{paths.join('/')}", default: 'DEFAULT')
        end
      end
    end
    paths.pop
    breadcrumb(paths, result << r)
  end

  def blockchain_url(txid)
    "https://blockchain.info/tx/#{txid}"
  end

  def qr_tag(data)
    data = QREncoder.encode(data).png.resize(272, 272).to_data_url
    image_tag(data, :class => 'qrcode img-thumbnail')
  end

  def otp_tag
    text_field_tag 'two_factor[otp]', '', class: 'form-control',
      step: 1, min: 100000, max: 999999, type: 'number',
      placeholder: t('simple_form.placeholders.defaults.otp')
  end

  def rev_category(type)
    type.to_sym == :bid ? :ask : :bid
  end

  def currency_icon(type)
    t("currency.icon.#{type}")
  end

  def currency_format(type)
    t("currency.format.#{type}")
  end

  def orders_json(orders)
    Jbuilder.encode do |json|
      json.array! orders do |order|
        json.id order.id
        json.bid order.bid
        json.ask order.ask
        json.category order.kind
        json.volume order.volume
        json.price order.price
        json.origin_volume order.origin_volume
        json.at order.created_at.to_i
      end
    end
  end

  def link_to_block(payment_address)
    uri = case payment_address.currency
    when 'btc' then btc_block_url(payment_address.address)
    end
    link_to t("actions.block"), uri, target: '_blank'
  end

  def btc_block_url(address)
    CoinRPC[:btc].getinfo[:testnet] ? "http://testnet.btclook.com/addr/#{address}" : "https://blockchain.info/address/#{address}"
  end

  def top_nav_link(link_text, link_path, link_icon, controllers: [])
    class_name = current_page?(link_path) ? 'active' : nil
    class_name ||= controllers.include?(controller_name) ? 'active' : nil

    content_tag(:li, :class => class_name) do
      link_to link_path do
        content_tag(:i, :class => "fa fa-#{link_icon}") do end + 
        content_tag(:span, link_text)
      end
    end
  end

  def simple_vertical_form_for(record, options={}, &block)
    result = simple_form_for(record, options, &block)
    result = result.gsub(/#{SimpleForm.form_class}/, "simple_form").html_safe
    result.gsub(/col-sm-\d/, "").html_safe
  end

  def panel(name: 'default-panel', key: nil, &block)
    key ||= "guides.#{i18n_controller_path}.#{action_name}.#{name}"

    content_tag(:div, :class => 'panel panel-default') do
      content_tag(:div, :class => 'panel-heading') do
        content_tag(:h3, :class => 'panel-title') do
          I18n.t(key)
        end
      end +
      content_tag(:div, :class => 'panel-body') do
        capture(&block)
      end
    end
  end

  def balance_panel(member: nil)
    member ||= current_user
    panel name: 'balance-pannel', key: 'guides.panels.balance' do
      render partial: 'private/shared/balances', locals: {member: member}
    end
  end

  def guide_panel_title
    t("guides.#{i18n_controller_path}.#{action_name}.panel", default: t("guides.#{i18n_controller_path}.panel"))
  end

  def guide_title
    t("guides.#{i18n_controller_path}.#{action_name}.title", default: t("guides.#{i18n_controller_path}.panel"))
  end

  def guide_intro
    t("guides.#{i18n_controller_path}.#{action_name}.intro", default: t("guides.#{i18n_controller_path}.intro", default: ''))
  end

  def i18n_controller_path
    @i18n_controller_path ||= controller_path.gsub(/\//, '.')
  end

  def language_path(lang=nil)
    lang ||= I18n.locale
    asset_path("languages/#{lang}.png")
  end

  def i18n_meta(key)
    t("#{i18n_controller_path}.#{action_name}.#{key}", default: :"layouts.meta.#{key}")
  end

  def description_for(name, &block)
    content_tag :dl, class: "dl-horizontal dl-#{name}" do
      capture(&block)
    end
  end

  def item_for(model, name, value = nil, &block)
    capture do
      if block_given?
        content_tag(:dt, model.class.human_attribute_name(name)) + 
          content_tag(:dd, capture(&block))
      else
        value = model.try(name)
        value = value.localtime if value.is_a? DateTime
        value = I18n.t(value) if value.is_a? TrueClass

        content_tag(:dt, model.class.human_attribute_name(name)) + 
          content_tag(:dd, value)
      end
    end
  end
end
