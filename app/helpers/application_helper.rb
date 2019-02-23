# encoding: UTF-8
# frozen_string_literal: true

module ApplicationHelper
  def check_active(klass)
    if klass.is_a? String
      return 'active' unless (controller.controller_path.exclude?(klass))
    else
      return 'active' if (klass.model_name.singular == controller.controller_name.singularize)
    end
  end

  def body_id
    "#{controller_name}-#{action_name}"
  end

  def description_for(name, &block)
    content_tag :dl, class: "dl-#{name} dl-horizontal" do
      capture(&block)
    end
  end

  def item_for(model_or_title, name='', value = nil, &block)
    if model_or_title.is_a? String or model_or_title.is_a? Symbol
      title = model_or_title
      capture do
        if block_given?
          content_tag(:dt, title.to_s) +
            content_tag(:dd, capture(&block))
        else
          value = name
          content_tag(:dt, title.to_s) +
            content_tag(:dd, value)
        end
      end
    else
      model = model_or_title
      capture do
        if block_given?
          content_tag(:dt, model.class.human_attribute_name(name)) +
            content_tag(:dd, capture(&block))
        else
          value ||= model.try(name)
          value = value.localtime if value.is_a? DateTime
          value = value if value.is_a? TrueClass

          content_tag(:dt, model.class.human_attribute_name(name)) +
            content_tag(:dd, value)
        end
      end
    end
  end

  def custom_stylesheet_link_tag_for(layout)
    if File.file?(Rails.root.join('public/custom-stylesheets', "#{layout}.css"))
      tag :link, \
        rel:   'stylesheet',
        media: 'screen',
        href:  "/custom-stylesheets/#{layout}.css"
    end
  end

end
