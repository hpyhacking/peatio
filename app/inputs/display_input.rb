class DisplayInput < SimpleForm::Inputs::Base
  def input
    value = input_html_options[:value] || object.send(attribute_name)
    template.content_tag(:p, value, class: 'form-control-static')
  end

  def additional_classes
    @additional_classes ||= [input_type].compact # original is `[input_type, required_class, readonly_class, disabled_class].compact`
  end
end
