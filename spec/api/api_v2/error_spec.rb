describe APIv2::Error do
  it do
    expect(APIv2::Error.new(text: 'Wrong argument.').inspect).to eq \
      '#<APIv2::Error: Wrong argument.>'
    expect(APIv2::AuthorizationError.new('Wrong password.').inspect).to eq \
      '#<APIv2::AuthorizationError: Authorization failed (Wrong password.)>'
  end
end
