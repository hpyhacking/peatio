# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|

  config.wrappers :inline, :tag => 'div', :class => 'control-inline form-group', :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input
    b.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline has-error' }
  end

  config.wrappers :dialog, :tag => 'div', :class => 'form-group', :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input
    b.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline has-error' }
  end

  config.button_class = 'btn btn-success'

  config.wrappers :bootstrap, :tag => 'div', :class => 'form-group', :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label

    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline has-error' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :horizontal, tag: 'div', class: 'form-group', error_class: 'has-error',
    defaults: { input_html: { class: 'form-group default_class' } } do |b|

    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder

    b.optional :pattern
    b.optional :readonly

    b.use :label, wrap_with: { tag: 'span', class: 'label-wrapper col-sm-2' }

    b.wrapper tag: 'div', class: 'col-sm-10' do |input_block|
      input_block.use :input
      input_block.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    end
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end

  config.wrappers :ordering, :tag => 'div', :class => 'control-inline form-group', :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label

    b.wrapper :tag => 'div', :class => 'controls' do |ba|
      ba.use :input
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline has-error' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
    end
  end

  config.wrappers :prepend, :tag => 'div', :class => "form-group", :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline has-error' }
    end
  end

  config.wrappers :append, :tag => 'div', :class => "form-group", :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => 'controls' do |input|
      input.wrapper :tag => 'div', :class => 'input-append' do |append|
        append.use :input
      end
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
      input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline has-error' }
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
