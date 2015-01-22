class DisplayInput < SimpleForm::Inputs::Base
  def input
    clip = input_options.delete(:clip)
    value = input_html_options[:value] || object.send(attribute_name)
    template.content_tag(:p, value, class: 'form-control-static') do
      template.concat template.content_tag(:span, value)
      if clip && value
        template.concat template.content_tag('i', '', class: 'fa fa-copy', data: {'clipboard-text' => value})
      end
    end
  end

  def additional_classes
    @additional_classes ||= [input_type].compact # original is `[input_type, required_class, readonly_class, disabled_class].compact`
  end
end
