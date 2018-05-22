describe ManagementAPIv1::Exceptions::Base do
  it do
    expect(ManagementAPIv1::Exceptions::Base.new(message: 'Wrong argument.').inspect).to eq \
      '#<ManagementAPIv1::Exceptions::Base: Wrong argument.>'
    expect(ManagementAPIv1::Exceptions::Base.new(message: 'Wrong argument.', debug_message: 'Debug message.').inspect).to eq \
      '#<ManagementAPIv1::Exceptions::Base: Wrong argument. (Debug message.)>'
  end
end
